module ACH
  class File < Component
    has_many :batches, lambda{ {:batch_number => batches.length + 1} }
    
    def control
      
      field_names = [:batch_count, :block_count, :entry_count, :entry_hash, :total_debit_amount, :total_credit_amount]
      control_fields = Hash[*field_names.zip(field_names.map{ |n| send n }).flatten]
      Control.new control_fields
    end
    private :control
    
    def batch_count
      batches.length
    end
    
    def block_count
      (file_entry_count / 10.0).ceil
    end
    
    def entry_count
      batches.map{ |b| b.entries.length }.inject(&:+) || 0
    end
    
    def entry_hash
      batches.map(&:entry_hash).compact.inject(&:+)
    end
    
    def total_debit_amount
      batches.map(&:total_debit_amount).compact.inject(&:+)
    end
    
    def total_credit_amount
      batches.map(&:total_credit_amount).compact.inject(&:+)
    end
    
    def to_ach
      [header] + batches.map(&:to_ach).flatten + [control]
    end
    
    def to_s!
      to_ach.map(&:to_s!).join("\n")
    end
    
    def write filename
      return false unless valid?
      File.open(filename, 'w') do |fh|
        fh.write(to_s!)
      end
    end
  end
end
