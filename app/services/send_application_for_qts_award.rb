# frozen_string_literal: true

class SendApplicationForQTSAward
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    in_verify_stage = assessment.verify?

    ActiveRecord::Base.transaction do
      assessment.award!
      if in_verify_stage
        AssignApplicationFormVerifier.call(application_form:, verifier: user)
      end
      CreateTRSTRNRequest.call(application_form:, user:)
    end
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment
end
