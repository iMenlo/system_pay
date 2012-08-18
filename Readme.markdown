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
      vads_site_id: '00000000'
      certificat: '0000000000000000'
      vads_validation_mode: 1
      vads_shop_name: 'My shop'
      vads_shop_url: 'www.example.com'
    production:
      vads_site_id: '00000000'
      certificat: '0000000000000000'
      vads_validation_mode: 0
      vads_shop_name: 'My shop'
      vads_shop_url: 'www.example.com'
      vads_ctx_mode: PRODUCTION
      
    # NB: you can place here any of the class variables
  
### in order controller :

    @system_pay = SystemPay::Vads.new(:amount => @order.amount_in_cents, :trans_id => @order.id)
    # NB: nil instance variables are ignored (not transmitted to the bank server)

### in order view :

    = form_tag @system_pay.target_url do
      = system_pay_hidden_fields(@system_pay)
      = submit_tag "Access to the bank website"

### in a controller for call back from the bank :

    class OrderTransactionsController < ApplicationController

      protect_from_forgery :except => [:bank_callback]

      def bank_callback
        @transaction = Transaction.where(:order_id => params[:vads_order_id], :state => ['sent', 'ready']).first if params[:vads_order_id] =~ /^[\d-]+$/
        unless @transaction
          logger.info "bank_callback ignored: no transaction matching order_id '#{params[:vads_order_id]}'."
        else
          # store whatever returned parameters you need, at least the payment_certificate:
          @transaction.payment_certificate  = params[:vads_payment_certificate]
          @transaction.result               = params[:vads_result].to_i
          @transaction.auth_result          = params[:vads_auth_result].to_i
          @transaction.extra_result         = params[:vads_extra_result].to_i
          @transaction.warranty_result      = params[:vads_warranty_result]
          @transaction.card_brand           = params[:vads_card_brand]
          begin
            @transaction.expiry_date        = DateTime.new(params[:vads_expiry_year].to_i, params[:vads_expiry_month].to_i, 1)
          rescue
            @transaction.expiry_date        = DateTime.now
          end
          
          # or store all returned parameters as text:
          @transaction.returned_params      = params.to_a.sort.map{|k,v| "#{k}: #{v}"}.join("\n")

          # get transaction result
          @result = SystemPay::Vads.diagnose(params)

          # store
          @transaction.tech_msg = @result[:tech_msg]
          @transaction.user_msg  = @result[:user_msg]
          @transaction.save

          # change state
          case @result[:status]
          when :success
            @transaction.success!
          when :cancel
            @transaction.cancel!    
          when :error
            @transaction.error!  
          when :bad_params
            @transaction.error!
          end
        end

        render :text => "Pragma: no-cache\nContent-type: text/plain\n\nversion=V2\nOK" 
      end

## Thanks

This gem is inspired by Novelys [paiement_cic](http://github.com/novelys/paiementcic), many thanks to the team.

## License
Copyright (c) 2012 iMenlo Team, released under the MIT license
    