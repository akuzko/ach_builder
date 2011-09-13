require 'spec_helper'

describe ACH::Formatter do
  before(:all) do
    module ACH::Formatter
      # redefining RULES FOR new test values
      RULES = RULES.dup
      RULES[:ljust_10] = '<-10'
      RULES[:ljust_10_transform] = '<-10|upcase'
      RULES[:rjust_10] = '->10'
      RULES[:rjust_10_spaced] = '->10-'
    end
  end
  
  it{ ACH::Formatter.ljust_10('FOO').should == 'FOO'.ljust(10) }
  
  it{ ACH::Formatter.ljust_10_transform('foo').should == 'FOO'.ljust(10) }
  
  it{ ACH::Formatter.rjust_10(1599).should == '1599'.rjust(10, '0') }
  
  it{ ACH::Formatter.rjust_10_spaced(1599).should == '1599'.rjust(10) }
end
