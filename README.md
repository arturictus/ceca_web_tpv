# Ceca web TPV

Add simple web payment tpv to your rails application

Example app source at: https://github.com/ritxi/sermepa_web_tpv_sample_app

Steps to use it:

1. Create a new rails application

	rails new payment_app

2. Add sermepa_web_tpv to your Gemfile

	gem 'sermepa_web_tpv'

3. Add a transaction model with an amount and transaction_number fields

	rails g model Transaction amount:float transaction_number:integer

4. Configure tpv options

```ruby
module MyApp
  class Application < Rails::Application
		# MerchantID
    config.web_tpv.merchant_code = '123456789' 
		# AcquirerBIN
    config.web_tpv.acquirer_bin = "1234567890" 
    config.web_tpv.terminal_id = "12345678"
    config.web_tpv.redirect_success_path = '/payments/success'
    config.web_tpv.redirect_failure_path = '/payments/failure'
    config.web_tpv.callback_response_path = '/payments/validate'
    config.web_tpv.currency = 978 # Euro
		# clave encriptación
    config.web_tpv.merchant_secret_key = '99888888' 
    config.web_tpv.bank_url = 'http://tpv.ceca.es:8000/cgi-bin/tpv'
    config.web_tpv.response_host = 'www.my_web.es'
  
   # Optionals
    config.web_tpv.language = 1 #castellano
    config.web_tpv.merchant_name = 'online shop'
  end
end
```

5. Add a controller payment to perform a new request payment and receive payment result

```ruby
MyApp::Application.routes.draw do
  get 'payments/new' => 'payments#new', :as => 'new_payment'
  post 'payments/validate' => 'payments#validate', :as => 'payment_validate'
  get  'payments/success' => 'payments#success', :as => 'payment_success'
  get  'payments/failure' => 'payments#failure', :as => 'payment_failure'
end
```

```ruby
class PaymentsController
  skip_before_filter :verify_authenticity_token

  def new
    transaction = Transaction.new(amount: 10)
    request = SermepaWebTpv::Request.new(transaction, "Transaction description")
    request.transact {|t| t.save }
    render json: { options: sermepa_request.options, url: sermepa_request.bank_url }
    # Submit a form with given options to the url
  end

  def success
    flash[:notice] = "Payment done successfuly!"
    redirect_to root_path
  end

  def failure
    flash[:failure] = "Payment failed, try again later."
    redirect_to root_path
  end

  def validate
    response = SermepaWebTpv::Response.new(params)
    if response.valid? && response.success?
      # mark your transaction as finished
    end
  end
end
```

