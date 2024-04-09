# frozen_string_literal: true

class FakeData::ApplicationFormParameters
  def initialize(
    submitted: false,
    pre_assessment: false,
    assessment: false,
    further_information: false,
    verification: false,
    review: false,
    requested: false,
    received: false,
    expired: false,
    awarded: false,
    declined: false
  )
    @submitted = submitted
    @pre_assessment = pre_assessment
    @assessment = assessment
    @further_information = further_information
    @verification = verification
    @review = review

    @requested = requested
    @received = received
    @expired = expired

    @awarded = awarded
    @declined = declined
  end

  def submit?
    @submitted || @pre_assessment || @assessment || @further_information ||
      @verification || @review || @awarded || @declined
  end

  def pre_assess?
    @pre_assessment || @assessment || @further_information || @verification ||
      @review || @awarded || @declined
  end

  def decline_after_pre_assessment?
    @pre_assessment && @declined
  end

  def assess?
    @assessment || @further_information || @verification || @review ||
      @awarded || @declined
  end

  def decline_after_assessment?
    @assessment && @declined
  end

  def request_further_information?
    @further_information
  end

  def receive_further_information?
    @further_information && (verify? || @received)
  end

  def decline_after_further_information?
    @further_information && @declined
  end

  def verify?
    @verification || @review || @awarded || @declined
  end

  def review?
    @review || (@verification && @declined)
  end

  def decline_after_review?
    (@review && @declined) || (@verification && @declined)
  end

  def receive_professional_standing?
    assess? || (@pre_assessment && @received)
  end

  def request_verification?
    review? || receive_verification? || expire_verification? ||
      (@verification && @requested)
  end

  def receive_verification?
    review? || award? || (@verification && @received)
  end

  def expire_verification?
    @verification && @expired
  end

  def award?
    @awarded
  end
end
