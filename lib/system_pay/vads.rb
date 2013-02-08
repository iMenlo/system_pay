# encoding: UTF-8
module SystemPay
  class Vads
    # pre-defined messages (from 2.2 Guide)
    VADS_RISK_CONTROL_RESULT = {
      ''   => 'Pas de contrôle effectué.',
      '00' => 'Tous les contrôles se sont déroulés avec succès.',
      '02' => 'La carte a dépassé l’encours autorisé.',
      '03' => 'La carte appartient à la liste grise du commerçant.',
      '04' => 'Le pays d’émission de la carte appartient à la liste grise du commerçant ou le pays d’émission de la carte n’appartient pas à la liste blanche du commerçant.',
      '05' => 'L’adresse IP appartient à la liste grise du commerçant.',
      '07' => 'La carte appartient à la liste grise BIN du commerçant.',
      '99' => 'Problème technique rencontré par le serveur lors du traitement d’un des contrôles locaux.',
    }
    VADS_QUERY_FORMAT_ERROR = {
      '01' => 'vads_version',
      '02' => 'vads_site_id',
      '03' => 'vads_trans_id',
      '04' => 'vads_trans_date',
      '05' => 'vads_validation_mode',
      '06' => 'vads_capture_delay',
      '07' => 'vads_payment_config',
      '08' => 'vads_payment_cards',
      '09' => 'vads_amount',
      '10' => 'vads_currency',
      '11' => 'vads_ctx_mode',
      '12' => 'vads_language',
      '13' => 'vads_order_id',
      '14' => 'vads_order_info',
      '15' => 'vads_cust_email',
      '16' => 'vads_cust_id',
      '17' => 'vads_cust_title',
      '18' => 'vads_cust_name',
      '19' => 'vads_cust_address',
      '20' => 'vads_cust_zip',
      '21' => 'vads_cust_city',
      '22' => 'vads_cust_country',
      '23' => 'vads_cust_phone',
      '24' => 'vads_url_success',
      '25' => 'vads_url_refused',
      '26' => 'vads_url_referral',
      '27' => 'vads_url_cancel',
      '28' => 'vads_url_return',
      '29' => 'vads_url_error',
      '31' => 'vads_contrib',
      '32' => 'vads_theme_config',
      '46' => 'vads_page_action',
      '47' => 'vads_action_mode',
      '48' => 'vads_return_mode',
      '61' => 'vads_user_info',
      '62' => 'vads_contracts',
      '77' => 'vads_cust_cell_phone'
    }

    # fixed params per shop are class variables
    @@target_url = "https://paiement.systempay.fr/vads-payment/"
    cattr_accessor :target_url

    @@vads_action_mode = 'INTERACTIVE'
    cattr_accessor :vads_action_mode

    @@vads_ctx_mode = 'TEST' # or 'PRODUCTION'
    cattr_accessor :vads_ctx_mode

    @@vads_contrib = 'Ruby'
    cattr_accessor :vads_contrib

    @@vads_page_action = 'PAYMENT'
    cattr_accessor :vads_page_action

    @@vads_payment_config = 'SINGLE'
    cattr_accessor :vads_payment_config

    @@vads_return_mode = 'POST' # or 'GET', but request in GET could be too large
    cattr_accessor :vads_return_mode

    @@vads_site_id = '000000'
    cattr_accessor :vads_site_id

    @@vads_validation_mode = '1'
    cattr_accessor :vads_validation_mode

    @@vads_version = 'V2'
    cattr_accessor :vads_version

    @@certificat = '0000000000000000'
    cattr_accessor :certificat

    @@vads_shop_name = ''
    cattr_accessor :vads_shop_name

    @@vads_shop_url = ''
    cattr_accessor :vads_shop_url

    # transaction parameters are instance variables
    attr_accessor :vads_amount, :vads_available_languages, :vads_capture_delay, :vads_contracts, :vads_currency,
      :vads_cust_address, :vads_cust_cell_phone, :vads_cust_city, :vads_cust_country, :vads_cust_email, :vads_cust_id,
      :vads_cust_name, :vads_cust_phone, :vads_cust_title, :vads_cust_zip, :vads_cust_city,
      :vads_language, :vads_order_id, :vads_order_info, :vads_order_info2, :vads_order_info3, :vads_payment_cards,
      :vads_redirect_error_message, :vads_redirect_error_timeout,
      :vads_redirect_success_message, :vads_redirect_success_timeout,
      :vads_ship_to_city, :vads_ship_to_country, :vads_ship_to_name, :vads_ship_to_phone_num, :vads_ship_to_state,
      :vads_ship_to_street, :vads_ship_to_street2, :vads_ship_to_zip, :vads_theme_config, :vads_trans_date,
      :vads_trans_id, :vads_url_cancel, :vads_url_error, :vads_url_referral, :vads_url_refused, :vads_url_success,
      :vads_url_return

    # Public: Creation of new instance.
    #
    # args - The hash of systempay parameters as described in the implementation
    #        document. Note that each key should *not* contain the vads_ prefix.
    #        :amount - Should be in cents
    #        :trans_id - Will be automatically padded with zeros
    #
    # Examples
    #
    #   SystemPay::Vads.new(:amount => 100, :trans_id => 10, :url_return => 'http://mywebsite.com/return_url')
    #
    # Returns a new instance object
    def initialize(args=nil)
      args.each do |k,v|
        if k.to_s.match(/^vads_/)
          instance_variable_set("@#{k}", v) if v.present? && respond_to?(k)
        else
          instance_variable_set("@vads_#{k}", v) if v.present? && respond_to?("vads_#{k}")
        end
      end if args

      raise ArgumentError.new("You must specify a non blank :amount parameter") unless @vads_amount.present?
      raise ArgumentError.new("You must specify a non blank :trans_id parameter") unless @vads_trans_id.present?

      @vads_currency ||= '978' # Euros
      @vads_trans_date ||= Time.now.utc.strftime("%Y%m%d%H%M%S")
      @vads_trans_id = (@vads_trans_id % 900000).to_s.rjust(6, '0')
    end

    # Public: Compute the signature of the request based on the parameters
    #
    # Returns the signature string
    def signature
      self.class.sign(sorted_values)
    end

    # Public: Hash with non-nil parameters (and value) and their signature
    #
    # Returns a hash
    def params
      Hash[sorted_array + [['signature', signature]]]
    end

    # Public: Verify that the returned signature is valid.
    # Return boolean
    def self.valid_signature?(params)
      vads_params = params.sort.select{|value| value[0].to_s.match(/^vads_/)}.map{|value| value[1]}
      sign(vads_params) == params['signature']
    end

    # Public: Diagnose result from returned params
    #
    # params - The hash of params returned by the bank.
    #
    # Returns a hash { :status => :error | :success | :canceled | :bad_params,
    #                  :user_msg => "msg for user",
    #                  :tech_msg => "msg for back-office" }
    def self.diagnose(params)
      if params[:vads_result].blank?
        { :status => :bad_params,
          :user_msg => 'Vous allez être redirigé vers la page d’accueil',
          :tech_msg => 'vads_result est vide. Suspicion de tentative de fraude.' }
      elsif !valid_signature?(params)
        { :status => :bad_params,
          :user_msg => 'Vous allez être redirigé vers la page d’accueil',
          :tech_msg => 'La signature ne correspond pas. Suspicion de tentative de fraude.' }
      else case params[:vads_result]
        when '00'
          { :status => :success,
            :user_msg => 'Votre paiement a été accepté par la banque.',
            :tech_msg => "Paiement accepté. #{VADS_RISK_CONTROL_RESULT[params[:vads_extra_result]]}" }
        when '02'
          { :status => :error,
            :user_msg => 'Nous devons entrer en relation avec votre banque avant d’obtenir confirmation du paiement.',
            :tech_msg => 'Le commerçant doit contacter la banque du porteur.' }
        when '05'
          { :status => :error,
            :user_msg => 'Le paiement a été refusé par la banque.',
            :tech_msg => "Paiement refusé par la banque. #{VADS_RISK_CONTROL_RESULT[params[:vads_extra_result]]}" }
        when '17'
          { :status => :canceled,
            :user_msg => 'Vous avez annulé votre paiement.',
            :tech_msg => 'Paiement annulé par le client.' }
        when '30'
          { :status => :bad_params,
            :user_msg => 'En raison d’une erreur technique, le paiement n’a pu être validé.',
            :tech_msg => "Erreur de format dans la requête (champ #{VADS_QUERY_FORMAT_ERROR[params[:vads_extra_result]]}). Signaler au développeur." }
        when '96'
          { :status => :bad_params,
            :user_msg => 'En raison d’une erreur technique, le paiement n’a pu être validé.',
            :tech_msg => 'Code vads_result inconnu. Signaler au développeur.' }
        else
          { :status => :bad_params,
            :user_msg => 'En raison d’une erreur technique, le paiement n’a pu être validé.',
            :tech_msg => 'Code vads_result inconnu. Signaler au développeur.' }
        end
      end
    end

  private

    def self.sign(values)
      Digest::SHA1.hexdigest((values+[certificat]).join("+"))
    end

    def instance_variables_array
      instance_variables.map { |name| v = instance_variable_get(name) ; v.nil? ? nil : [name[1..-1], v] }.compact
    end

    def self.class_variables_array
      class_variables.select{|name| name.match(/^@@vads_/)}.map { |name| [name[2..-1], class_variable_get(name)] }
    end

    def sorted_array
      (instance_variables_array + self.class.class_variables_array).uniq.sort
    end

    def sorted_values
      sorted_array.map{|value| value[1]}
    end

  end
end
