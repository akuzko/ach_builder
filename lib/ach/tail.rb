module ACH
  class Tail < Record
    fields :nines
    defaults :nines => '9' * RECORD_SIZE
  end
end
