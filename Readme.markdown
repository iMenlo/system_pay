# SystemPay

SystemPay is a gem to ease credit card payment with Natixis Paiements / CyberplusPaiement (Banque Populaire) bank system. It's a Ruby on Rails port of the connexion kits published by the bank. 

* Gem Homepage : [http://github.com/iMenlo/system_pay](http://github.com/iMenlo/system_pay)
* Cyberplus SystemPay documentation : [https://systempay.cyberpluspaiement.com](https://systempay.cyberpluspaiement.com)

## INSTALL

    gem install system_pay

or, in your Gemfile

    gem 'system_pay'
    
## USAGE

   Create a config yml data file to store your site_id and certificates values:

### in config/system_pay.yml:

    development:
      vads_site_id : '00000000'
      certificat: '0000000000000000'
    production:
      vads_site_id : '00000000'
      certificat: '0000000000000000'
      vads_ctx_mode: PRODUCTION
  
### in order controller :

    @system_pay = SystemPay::Vads.new(:amount => @order.amount_in_cents, :trans_id => @order.id)   

### in order view :

    = form_tag @system_pay.target_url do
      = system_pay_hidden_fields(@system_pay)
      = submit_tag "Access to the bank website"

### in a controller for call back from the bank :

    class OrderTransactionsController < ApplicationController

      protect_from_forgery :except => [:bank_callback]

      def bank_callback
        @system_pay = SystemPay::Vads.new(params)
        if SystemPay::Vads.valid_signature?(@system_pay.params)
        
          order_transaction = OrderTransaction.find_by_reference params[:reference], :last
          order = order_transaction.order

          return_code = params['vads_result']

          if return_code == "Annulation"
            order.cancel!
            order.update_attribute :description, "Paiement refusé par la banque."

          elsif return_code == "payetest"
            order.pay!
            order.update_attribute :description, "TEST accepté par la banque."
            order_transaction.update_attribute :test, true

          elsif return_code == "00"
            order.pay!
            order.update_attribute :description, "Paiement accepté par la banque."
            order_transaction.update_attribute :test, false
          end

          order_transaction.update_attribute :success, true
      
          receipt = "0"
        else
          order.transaction_declined!
          order.update_attribute :description, "Document Falsifie."
          order_transaction.update_attribute :success, false

          receipt = "1\n#{PaiementCic.mac_string}"
        end
        render :text => "Pragma: no-cache\nContent-type: text/plain\n\nversion=2\ncdr=#{receipt}"
      end


## Thanks

This gem is inspired by Novelys [paiement_cic](http://github.com/novelys/paiementcic), many thanks to the team.

## License
Copyright (c) 2012 iMenlo Team, released under the MIT license
    