# frozen_string_literal: true
module Ecpay
  # Generic Ecpay exception class.
  class EcpayError < StandardError; end
  class MissingOption < EcpayError; end
  class InvalidMode < EcpayError; end
end
