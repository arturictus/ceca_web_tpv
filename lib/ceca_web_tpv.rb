require 'active_support/core_ext/module/attribute_accessors'
module CecaWebTpv
  #  config example
  #
  # config.web_tpv.merchant_code = '123456789' [MerchantID]
  # config.web_tpv.acquirer_bin = "1234567890"  [AcquirerBIN]
  # config.web_tpv.terminal_id = "12345678"
  # config.web_tpv.redirect_success_path = '/payments/success'
  # config.web_tpv.redirect_failure_path = '/payments/failure'
  # config.web_tpv.callback_response_path = '/payments/validate'
  # config.web_tpv.currency = 978 # Euro
  # config.web_tpv.merchant_secret_key = '99888888' [clave encriptación]
  # config.web_tpv.bank_url = 'http://tpv.ceca.es:8000/cgi-bin/tpv'
  # config.web_tpv.response_host = 'www.my_web.es'
  
  # Optionals
  # config.web_tpv.language = 1 #castellano
  # config.web_tpv.merchant_name = 'RECAMBIOS ARNYX'
  


  mattr_accessor :transaction_model_transaction_number_attribute
  @@transaction_model_transaction_number_attribute = :transaction_number

  mattr_accessor :transaction_model_amount_attribute
  @@transaction_model_amount_attribute = :amount

  mattr_accessor :bank_url
  @@bank_url = 'https://pgw.ceca.es/cgi-bin/tpv'

  mattr_accessor :terminal
  @@terminal = 1

  mattr_accessor :merchant_secret_key

  mattr_accessor :currency
  @@currency = 978 # Euro

  mattr_accessor :merchant_code

  mattr_accessor :transaction_type
  @@transaction_type = 0

  mattr_accessor :language
  @@language = '003' #Catala

  mattr_accessor :response_host
  @@response_host = '' #'shop_name.com'

  mattr_accessor :callback_response_path
  @@callback_response_path = '' #"/payments/callback"

  # Optional
  mattr_accessor :merchant_name
  @@merchant_name = '' #'shop name'

  mattr_accessor :redirect_success_path
  @@redirect_success_path = nil #"/payments/success"

  mattr_accessor :redirect_failure_path
  @@redirect_failure_path = nil #"/payments/failure"
  
  #
  # CECA IMplementation
  #
  mattr_accessor :acquirer_bin
  @@acquirer_bin = ""
  mattr_accessor :terminal_id
  @@terminal_id = "00000003"
  #
  #
  #

  autoload :Request, 'ceca_web_tpv/request'
  autoload :Response, 'ceca_web_tpv/response'

end
require 'ceca_web_tpv/persistence/active_record'
require 'ceca_web_tpv/railtie'