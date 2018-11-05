# frozen_string_literal: true
require 'net/http'
require 'json'
require 'cgi'
require 'digest'
require 'ecpay/errors'
require 'ecpay/core_ext/hash'

module Ecpay
  class Client # :nodoc:
    PRODUCTION_API_HOST = 'https://payment.ecpay.com.tw'
    TEST_API_HOST = 'https://payment-stage.ecpay.com.tw'
    TEST_OPTIONS = {
      merchant_id: '2000132',
      hash_key: '5294y06JbISpM5x9',
      hash_iv: 'v77hoKGq4kWxNNIS'
    }.freeze

    attr_reader :options

    def initialize(options = {})
      @options = { mode: :production,
                   gateway_type: :payment }.merge!(options)
      case @options[:mode]
      when :production
        option_required! :merchant_id, :hash_key, :hash_iv
      when :test
        @options = TEST_OPTIONS.merge(options)
      else
        raise InvalidMode, %(option :mode is either :test or :production)
      end
      @options.freeze
    end

    def api_host
      case @options[:mode]
      when :production then PRODUCTION_API_HOST
      when :test then TEST_API_HOST
      end
    end

    def make_mac(params = {})
      raw = params.sort_by { |k, _v| k.downcase }.map! { |k, v| "#{k}=#{v}" }.join('&')
      padded = "HashKey=#{@options[:hash_key]}&#{raw}&HashIV=#{@options[:hash_iv]}"
      url_encoded = CGI.escape(padded).downcase!

      convert_to_dot_net(url_encoded)

      return Digest::MD5.hexdigest(url_encoded).upcase! if @options[:gateway_type] == :logistic
      Digest::SHA256.hexdigest(url_encoded).upcase!
    end

    def verify_mac(params = {})
      stringified_keys = params.stringify_keys
      check_mac_value = stringified_keys.delete('CheckMacValue')
      make_mac(stringified_keys) == check_mac_value
    end

    def generate_params(overwrite_params = {})
      result = overwrite_params.clone
      result[:MerchantID] = @options[:merchant_id]
      result[:CheckMacValue] = make_mac(result)
      result
    end

    def generate_checkout_params(overwrite_params = {})
      generate_params({
        MerchantTradeNo: SecureRandom.hex(4),
        MerchantTradeDate: Time.now.strftime('%Y/%m/%d %H:%M:%S'),
        PaymentType: 'aio',
        EncryptType: 1
      }.merge!(overwrite_params))
    end

    def request(path, params = {})
      api_url = URI.join(api_host, path)
      Net::HTTP.post_form api_url, generate_params(params)
    end

    def query_trade_info(merchant_trade_number, platform = nil)
      params = {
        MerchantTradeNo: merchant_trade_number,
        TimeStamp: Time.now.to_i,
        PlatformID: platform
      }
      params.delete_if { |_k, v| v.nil? }
      res = request('/Cashier/QueryTradeInfo/V2', params)

      Hash[res.body.split('&').map! { |i| i.split('=') }]
    end

    def query_credit_card_period_info(merchant_trade_number)
      res = request(
        '/Cashier/QueryCreditCardPeriodInfo',
        MerchantTradeNo: merchant_trade_number,
        TimeStamp: Time.now.to_i
      )

      JSON.parse(res.body)
    end

    private

    def convert_to_dot_net(url_encoded)
      url_encoded.gsub!('%2d', '-')
      url_encoded.gsub!('%5f', '_')
      url_encoded.gsub!('%2e', '.')
      url_encoded.gsub!('%21', '!')
      url_encoded.gsub!('%2a', '*')
      url_encoded.gsub!('%28', '(')
      url_encoded.gsub!('%29', ')')
    end

    def option_required!(*option_names)
      option_names.each do |option_name|
        raise MissingOption, %(option "#{option_name}" is required.) if @options[option_name].nil?
      end
    end
  end
end
