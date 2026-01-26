# frozen_string_literal: true

class GovUKPay::CreatePaymentParams
  include ServicePattern

  def initialize(reference:, email:, amount:)
    @reference = reference
    @amount = amount
    @email = email
  end

  def call
    {
      reference:,
      description:,
      amount:,
      email:,
      return_url: ,
    }
  end

  private

  def return_url
    # Currently we'll use the reference in the path, but if we were to
    # productionise this, we'll look at generating a new table for
    # payment_transactions which will hold information about the
    # initiated payment and any returned payment_id and statuses
    # by GOV.UK Pay.
    callback_path = "/teacher/application/payment-transactions/#{reference}"

    if HostingEnvironment.development?
      "http://localhost:3000#{callback_path}"
    else
      "https://#{HostingEnvironment.host}#{callback_path}"
    end
  end

  def description
    "Apply for QTS in England application fee"
  end

  attr_reader :reference, :amount, :email
end
