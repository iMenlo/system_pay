require 'spec_helper'

describe SystemPay do

  context "configuration" do
    before(:each) do
      SystemPay::Vads.vads_site_id = nil
      SystemPay::Vads.certificat = nil
      SystemPay::Vads.vads_ctx_mode = nil
      SystemPay::Vads.vads_contrib = nil            
    end
    
    it "should allow setting of the vads_site_id" do
      SystemPay::Vads.vads_site_id = '228159'
      SystemPay::Vads.vads_site_id.should == '228159'
    end
    
    it "should allow setting of the certificate" do
      SystemPay::Vads.certificat = '1234194862125022'
      SystemPay::Vads.certificat.should == '1234194862125022'
    end 
    
    it "should allow setting of the production mode" do
      SystemPay::Vads.vads_ctx_mode = 'PRODUCTION'
      SystemPay::Vads.vads_ctx_mode.should == 'PRODUCTION'
    end  
    
    it "should allow setting of the contribution name" do
      SystemPay::Vads.vads_contrib = 'Rspec'
      SystemPay::Vads.vads_contrib.should == 'Rspec'
    end                
    
    
  end
  
  before(:all) do
    SystemPay::Vads.vads_site_id = '654321'
    SystemPay::Vads.certificat = '8877665544332211'
  end    
  
  describe '.new' do
    it 'should raise an error if the amount parameter is not set' do
      lambda do
        system_pay = SystemPay::Vads.new(:trans_id => 1)
      end.should raise_error(ArgumentError)
    end
    
    it 'should raise an error if the trans_id parameter is not set' do
      lambda do
        system_pay = SystemPay::Vads.new(:amount => 100)
      end.should raise_error(ArgumentError)
    end 
    
    it 'should pass with trans_id and amount parameters passed' do
      lambda do
        system_pay = SystemPay::Vads.new(:amount => 100, :trans_id => 2)
      end.should_not raise_error
    end        
      
  end
  
  describe '#signature' do
 
    it 'should return a correct signature' do
      system_pay = SystemPay::Vads.new(:amount => 100, :trans_id => 2, :trans_date => "20120420121326")
      system_pay.signature.should == 'f5bec689b57ebefa81c84d184f4bca05e7e8e106'
    end   
  
  end
  
  describe '#params' do
  
    it 'should return the params to pass to the bank' do
      system_pay = SystemPay::Vads.new(:amount => 100, :trans_id => 2, :trans_date => "20120420121326")
      params = {"vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>nil, "vads_contrib"=>"Rspec", "vads_action_mode"=>"INTERACTIVE", "vads_page_action"=>"PAYMENT", "vads_validation_mode"=>"1", "vads_shop_url"=>"", "vads_trans_id"=>"000002", "vads_site_id"=>nil, "signature"=>"f5bec689b57ebefa81c84d184f4bca05e7e8e106", "vads_return_mode"=>"POST", "vads_currency"=>"978", "vads_shop_name"=>"", "vads_amount"=>100, "vads_version"=>"V2", "vads_trans_date"=>"20120420121326"}

      system_pay.params.should == params
    end     
    
  end
  
  describe '.valid_signature?' do
  
    it 'should return true when valid params are entered' do
      params = {"vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>nil, "vads_contrib"=>"Rspec", "vads_action_mode"=>"INTERACTIVE", "vads_page_action"=>"PAYMENT", "vads_validation_mode"=>"1", "vads_shop_url"=>"", "vads_trans_id"=>"000002", "vads_site_id"=>nil, "signature"=>"f5bec689b57ebefa81c84d184f4bca05e7e8e106", "vads_return_mode"=>"POST", "vads_currency"=>"978", "vads_shop_name"=>"", "vads_amount"=>100, "vads_version"=>"V2", "vads_trans_date"=>"20120420121326"}

      SystemPay::Vads.valid_signature?(params).should be_true
    end  
    
    it 'should return false when invalid params are entered' do
      params = {"vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>nil, "vads_contrib"=>"Rspec", "vads_action_mode"=>"INTERACTIVE", "vads_page_action"=>"PAYMENT", "vads_validation_mode"=>"1", "vads_shop_url"=>"", "vads_trans_id"=>"000002", "vads_site_id"=>nil, "signature"=>"f6bec689b57ebefa81c84d184f4bca05e7e8e106", "vads_return_mode"=>"POST", "vads_currency"=>"978", "vads_shop_name"=>"", "vads_amount"=>100, "vads_version"=>"V2", "vads_trans_date"=>"20120420121326"}

      SystemPay::Vads.valid_signature?(params).should be_false
    end         
    
  end  


end