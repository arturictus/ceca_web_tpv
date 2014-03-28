require 'uri'
require 'digest/sha1'

module SermepaWebTpv
  class Request < Struct.new(:transaction, :description)
    include SermepaWebTpv::Persistence::ActiveRecord

    def bank_url
      SermepaWebTpv.bank_url
    end

    def options
      optional_options.merge(must_options)
    end

    def transact(&block)
      generate_transaction_number!
      yield(transaction)
      self
    end

    private

    def transaction_number_attribute
      SermepaWebTpv.transaction_model_transaction_number_attribute
    end

    def transaction_model_amount_attribute
      SermepaWebTpv.transaction_model_amount_attribute
    end

    def amount
      (transaction_amount * 100).to_i.to_s
    end

    def must_options
      {
        'MerchantID'      =>  SermepaWebTpv.merchant_code,
        'AcquirerBIN'     =>  SermepaWebTpv.acquirer_bin,
        'TerminalID'      =>  SermepaWebTpv.terminal_id,
        'URL_OK'          =>  url_for(:redirect_success_path),
        'URL_NOK'         =>  url_for(:redirect_failure_path),
        'Firma'           =>  signature,
        'Cifrado'         =>  'SHA1',
        'Num_operacion'   =>  transaction_number,
        'Importe'         =>  amount,
        'TipoMoneda'      =>  SermepaWebTpv.currency,
        'Exponente'       =>  "2",
        'Pago_soportado'  =>  "SSL"
      }
    end

    def signature
      hash = {
        clave_encriptacion: SermepaWebTpv.merchant_secret_key,
        merchant_id:        SermepaWebTpv.merchant_code,
        acquirer_bin:       SermepaWebTpv.acquirer_bin,
        terminal_id:        SermepaWebTpv.terminal_id,
        num_operacion:      transaction_number,
        importe:            amount,
        tipo_moneda:        SermepaWebTpv.currency,
        exponente:          "2",
        cifrado:            'SHA1',
        url_ok:             url_for(:redirect_success_path),
        url_nok:            url_for(:redirect_failure_path)
      }
      
      str = ""
      hash.each do |key, value|
        str += value.to_s
      end
      
      Digest::SHA1.hexdigest(str).downcase
    
    end

    # Available options
    # redirect_success_path
    # redirect_failure_path
    # callback_response_path
    def url_for(option)
      host = SermepaWebTpv.response_host
      path = SermepaWebTpv.send(option)

      if host.present? && path.present?
        URI.join("http://#{host}", path).to_s
      end
    end

    def optional_options
      {
        'Descripcion' => description,
        'Idioma'          =>  SermepaWebTpv.language
      }.delete_if {|key, value| value.blank? }
    end


  end
end