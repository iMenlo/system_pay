module SystemPay::FormHelper

  def system_pay_hidden_fields(system_pay)
  
    res = "\n"  
    system_pay.params.each{|key, value|
      res << hidden_field_tag(key, value) << "\n"
    }
    res.html_safe
  
  end

end