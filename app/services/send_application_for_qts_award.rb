# frozen_string_literal: true

class SendApplicationForQTSAward
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      assessment.award!
      AssignApplicationFormVerifier.call(application_form:, verifier: user)
      CreateTRSTRNRequest.call(application_form:, user:)
    end
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment
end
