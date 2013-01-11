# encoding: UTF-8
require 'system_pay/form_helper'
require 'rails'

module SystemPay
  class Railtie < ::Rails::Railtie
    initializer "system_pay.form_helper" do
      ActiveSupport.on_load(:action_controller) do 
        helper SystemPay::FormHelper
      end

=begin      
      config.to_prepare do
        self.setup! # &method(:activate).to_proc
      end
=end

      system_pay_config_file = File.join(Rails.root,'config','system_pay.yml')
      raise "#{system_pay_config_file} is missing!" unless File.exists? system_pay_config_file
      system_pay_config = YAML.load_file(system_pay_config_file)[Rails.env].symbolize_keys

      system_pay_config.each_pair do |n, v|
        SystemPay::Vads.class_variable_set("@@#{n}", v)
      end
    end
  end
end