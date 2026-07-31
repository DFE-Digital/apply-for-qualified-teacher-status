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
      if application_form_in_verification_stage?
        AssignApplicationFormVerifier.call(application_form:, verifier: user)
      end
      CreateTRSTRNRequest.call(application_form:, user:)
    end
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment

  def application_form_in_verification_stage?
    application_form.verification_stage?
  end
end
