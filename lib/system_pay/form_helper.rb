module SystemPay
  module FormHelper
    def system_pay_hidden_fields(system_pay)
      res = "\n"  
      system_pay.params.each do |key, value|
        res << hidden_field_tag(key, value) << "\n"
      end
      res.html_safe
    end
  end
end