module ACH
  class File::Control < Record
    fields :record_type,
      :batch_count,
      :block_count,
      :entry_count,
      :entry_hash,
      :total_debit_amount,
      :total_credit_amount,
      :bank_39
    
    defaults :record_type => 9,
      :bank_39            => ''
  end
end
