require 'active_support/inflector'
require 'active_support/ordered_hash'

require "ach/version"

require 'ach/formatter'
require 'ach/validations'
require 'ach/component'
require 'ach/record'
require 'ach/entry'
require 'ach/batch'
require 'ach/batch/header'
require 'ach/batch/control'
require 'ach/file'
require 'ach/file/header'
require 'ach/file/control'

module ACH
  
end

=begin

file = ACH::File.new(:company_id => '11-11111', :company_name => 'MY COMPANY') do
  company_entry_descr 'TV-TELCOM'
  immediate_dest '123123123'
  immediate_dest_name 'COMMERCE BANK'
  immediate_origin '123123123'
  immediate_origin_name 'MYCOMPANY'
  
  ['WEB', 'TEL'].each do |code|
    batch(:entry_class_code => code) do
      entry :customer_name => 'JOHN SMITH',
        :customer_acct     => '61242882282',
        :amount            => '2501',
        :routing_number    => '010010101',
        :bank_account      => '103030030'
    end
  end
end

file.write('ach_01.txt')

=end