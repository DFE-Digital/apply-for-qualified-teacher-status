# frozen_string_literal: true

class GovUKPay::Client::CreatePayment
  include ServicePattern
  include GovUKPay::Client::Connection

  def initialize(reference:, email:, amount:)
    @reference = reference
    @email = email
    @amount = amount
  end

  def call
    path = "/v1/payments"
    body = GovUKPay::CreatePaymentParams.call(reference:, email:, amount:)

    response =
      connection.post(path) do |req|
        req.body = body
      end

    response.body.transform_keys { |key| key.underscore.to_sym }
  end

  private

  attr_reader :reference, :email, :amount
end
