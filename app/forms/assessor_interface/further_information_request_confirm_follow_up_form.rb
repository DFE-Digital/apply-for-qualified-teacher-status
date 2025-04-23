# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestConfirmFollowUpForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :further_information_request, :user
  validates :further_information_request, :user, presence: true

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      ReviewRequestable.call(
        requestable: further_information_request,
        user:,
        passed: false,
        note: "Further information requested",
      )

      FurtherInformationRequests::CreateFromFurtherInformationReview.call(
        further_information_request:,
        user:,
      )
    end

    true
  end
end
