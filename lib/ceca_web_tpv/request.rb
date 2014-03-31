require 'uri'
require 'digest/sha1'

module CecaWebTpv
  class Request < Struct.new(:transaction, :description)
    include CecaWebTpv::Persistence::ActiveRecord

    def bank_url
      CecaWebTpv.bank_url
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
      CecaWebTpv.transaction_model_transaction_number_attribute
    end

    def transaction_model_amount_attribute
      CecaWebTpv.transaction_model_amount_attribute
    end

    def amount
      (transaction_amount * 100).to_i.to_s
    end

    def must_options
      {
        'MerchantID'      =>  CecaWebTpv.merchant_code,
        'AcquirerBIN'     =>  CecaWebTpv.acquirer_bin,
        'TerminalID'      =>  CecaWebTpv.terminal_id,
        'URL_OK'          =>  url_for(:redirect_success_path),
        'URL_NOK'         =>  url_for(:redirect_failure_path),
        'Firma'           =>  signature,
        'Cifrado'         =>  'SHA1',
        'Num_operacion'   =>  transaction_number,
        'Importe'         =>  amount,
        'TipoMoneda'      =>  CecaWebTpv.currency,
        'Exponente'       =>  "2",
        'Pago_soportado'  =>  "SSL"
      }
    end

    def signature
      hash = {
        clave_encriptacion: CecaWebTpv.merchant_secret_key,
        merchant_id:        CecaWebTpv.merchant_code,
        acquirer_bin:       CecaWebTpv.acquirer_bin,
        terminal_id:        CecaWebTpv.terminal_id,
        num_operacion:      transaction_number,
        importe:            amount,
        tipo_moneda:        CecaWebTpv.currency,
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
      host = CecaWebTpv.response_host
      path = CecaWebTpv.send(option)

      if host.present? && path.present?
        URI.join("http://#{host}", path).to_s
      end
    end

    def optional_options
      {
        'Descripcion' => description,
        'Idioma'          =>  CecaWebTpv.language
      }.delete_if {|key, value| value.blank? }
    end


  end
end