require "uuidtools"
require "json"
require "net/http"

require "cielo/api30/request/cielo_error"

module Cielo
  module API30
    module Request
      class CieloRequest
        attr_accessor :merchant
        private :merchant

        def initialize(merchant)
          @merchant = merchant
        end

        protected
        def send_request(method, uri, data=nil)
          body = nil
          headers = {"User-Agent" => "CieloEcommerce/3.0 Ruby SDK",
                     "RequestId" => UUIDTools::UUID.random_create.to_s,
                     "MerchantId" => merchant.merchant_id,
                     "MerchantKey" => merchant.merchant_key}

          if data.nil?
            headers["Content-Length"] = "0"
          else
            headers["Content-Type"] = "application/json"
            body = data.to_json
          end

          client = Net::HTTP.new(uri.host, uri.port)
          client.use_ssl = true

          response = client.send_request(method, uri.request_uri, body, headers)
          Rails.logger.warn "CIELO: #{response}"
          Rails.logger.warn "CIELO: #{response.code}"
          Rails.logger.warn "CIELO: #{response.class.name}"
          Rails.logger.warn "CIELO: #{response.body}"
          Rails.logger.warn "Cielo un: #{response.is_a?(Net::HTTPUnauthorized)}"
          Rails.logger.warn "Cielo suc: #{response.is_a?(Net::HTTPSuccess)}"

          data = JSON.parse(response.body)
          Rails.logger.warn "Cielo DATA: #{data}"

          raise CieloError.new(data.first["Code"], data.first["Message"]) if response.code.to_i >= 400

          data
        end
      end
    end
  end
end
