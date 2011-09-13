module ACH
  class Batch < Component
    has_many :entries
    
    def has_credit?
      entries.any?(&:credit?)
    end
    
    def has_debit?
      entries.any?(&:debit?)
    end
    
    def control
      field_names = [:entry_count, :entry_hash, :total_debit_amount, :total_credit_amount]
      control_fields = Hash[*field_names.zip(field_names.map{ |n| send n }).flatten]
      Control.new control_fields
    end
    
    def entry_count
      entries.length
    end
    
    def entry_hash
      entries.map{ |e| e.routing_number.to_i / 10 }.compact.inject(&:+)
    end
    
    def total_debit_amount
      entries.select(&:debit?).map(&:amount).compact.inject(&:+)
    end
    
    def total_credit_amount
      entries.select(&:credit?).map(&:amount).compact.inject(&:+)
    end
    
    def to_ach
      [header] + entries + [control]
    end
    
    def before_header
      attributes[:service_class_code] ||= (has_debit? && has_credit? ? 200 : has_debit? ? 225 : 220)
    end
  end
end
