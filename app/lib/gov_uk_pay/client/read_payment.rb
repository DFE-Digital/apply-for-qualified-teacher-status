# frozen_string_literal: true

class GovUKPay::Client::ReadPayment
  include ServicePattern
  include GovUKPay::Client::Connection

  attr_reader :payment_id

  def initialize(payment_id:)
    @payment_id = payment_id
  end

  def call
    path = "/v1/payments/#{payment_id}"
    response = connection.get(path)

    response.body.transform_keys { |key| key.underscore.to_sym }
  end
end
