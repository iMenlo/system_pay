# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "system_pay/version"

Gem::Specification.new do |s|
  s.name      = 'system_pay'
  s.version   = SystemPay::VERSION
  s.platform  = Gem::Platform::RUBY

  s.summary = "Ruby wrapper for Natixis Paiements / CyberplusPaiement payment api"
  s.description = "SystemPay is a gem to ease credit card payment with Natixis Paiements / CyberplusPaiement bank system. It's a Ruby on Rails port of the connexion kits published by the bank."

  s.authors   = ['Sylvain Gautier (iMenlo)']
  s.email     = ['sylvain@imenlo.com']
  s.homepage  = 'https://github.com/iMenlo/system_pay'

  # ensure the gem is built out of versioned files
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end