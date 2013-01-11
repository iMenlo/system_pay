require 'spec_helper'

describe SystemPay do

  context "configuration" do
    before(:each) do
      SystemPay.vads_site_id = nil
      SystemPay.certificat = nil
      SystemPay.vads_ctx_mode = nil
      SystemPay.vads_contrib = nil            
    end
    
    it "should allow setting of the vads_site_id" do
      SystemPay.vads_site_id = '228159'
      SystemPay.vads_site_id.should == '228159'
    end
    
    it "should allow setting of the certificate" do
      SystemPay.certificat = '1234194862125022'
      SystemPay.certificat.should == '1234194862125022'
    end 
    
    it "should allow setting of the production mode" do
      SystemPay.vads_ctx_mode = 'PRODUCTION'
      SystemPay.vads_ctx_mode.should == 'PRODUCTION'
    end  
    
    it "should allow setting of the contribution name" do
      SystemPay.vads_contrib = 'Rspec'
      SystemPay.vads_contrib.should == 'Rspec'
    end                
    
    
  end
  
  before(:all) do
    SystemPay.vads_site_id = '654321'
    SystemPay.certificat = '8877665544332211'
  end    
  
  describe '.new' do
    it 'should raise an error if the amount parameter is not set' do
      lambda do
        system_pay = SystemPay.new(:trans_id => 1)
      end.should raise_error(ArgumentError)
    end
    
    it 'should raise an error if the trans_id parameter is not set' do
      lambda do
        system_pay = SystemPay.new(:amount => 100)
      end.should raise_error(ArgumentError)
    end 
    
    it 'should pass with trans_id and amount parameters passed' do
      lambda do
        system_pay = SystemPay.new(:amount => 100, :trans_id => 2)
      end.should_not raise_error
    end        
      
  end
  
  describe '#signature' do
 
    it 'should return a correct signature' do
      system_pay = SystemPay.new(:amount => 100, :trans_id => 2, :trans_date => "20120420121326")
      system_pay.signature.should == '093a1ab754a569434c708528a167732c4fb98c34'
    end   
  
  end
  
  describe '#params' do
  
    it 'should return the params to pass to the bank' do
      system_pay = SystemPay.new(:amount => 100, :trans_id => 2, :trans_date => "20120420121326")
      params = {"vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>nil, "vads_contrib"=>"Rspec", "vads_action_mode"=>"INTERACTIVE", "vads_page_action"=>"PAYMENT", "vads_validation_mode"=>"1", "vads_trans_id"=>"000002", "vads_site_id"=>nil, "signature"=>"093a1ab754a569434c708528a167732c4fb98c34", "vads_return_mode"=>"GET", "vads_currency"=>"978", "vads_amount"=>100, "vads_version"=>"V2", "vads_trans_date"=>"20120420121326"}

      system_pay.params.should == params
    end     
    
  end
  
  describe '.valid_signature?' do
  
    it 'should return true when valid params are entered' do
      params = {"vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>nil, "vads_contrib"=>"Rspec", "vads_action_mode"=>"INTERACTIVE", "vads_page_action"=>"PAYMENT", "vads_validation_mode"=>"1", "vads_trans_id"=>"000002", "vads_site_id"=>nil, "signature"=>"093a1ab754a569434c708528a167732c4fb98c34", "vads_return_mode"=>"GET", "vads_currency"=>"978", "vads_amount"=>100, "vads_version"=>"V2", "vads_trans_date"=>"20120420121326"}

      SystemPay.valid_signature?(params).should be_true
    end  
    
    it 'should return false when invalid params are entered' do
      params = {"vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>nil, "vads_contrib"=>"Rspec", "vads_action_mode"=>"INTERACTIVE", "vads_page_action"=>"PAYMENT", "vads_validation_mode"=>"1", "vads_trans_id"=>"000002", "vads_site_id"=>nil, "signature"=>"093a1ab754a569434c708528a167732c4fb98c32", "vads_return_mode"=>"GET", "vads_currency"=>"978", "vads_amount"=>100, "vads_version"=>"V2", "vads_trans_date"=>"20120420121326"}

      SystemPay.valid_signature?(params).should be_false
    end         
    
  end  


end