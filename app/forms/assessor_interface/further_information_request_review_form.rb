# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestReviewForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :further_information_request, :user
  validates :further_information_request, :user, presence: true

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      further_information_request.items.each do |item|
        review_decision = send("#{item.id}_decision")

        item.update!(review_decision:)
      end
    end

    if all_further_information_request_items_accepted?
      ReviewRequestable.call(
        requestable: further_information_request,
        user:,
        passed: true,
        note: "",
      )
    end

    true
  end

  def all_further_information_request_items_accepted?
    further_information_request.items.all?(&:review_decision_accept?)
  end

  def follow_up_further_information_requested?
    further_information_request.items.any?(
      &:review_decision_further_information?
    ) && further_information_request.items.none?(&:review_decision_decline?)
  end

  class << self
    def for_further_information_request(further_information_request)
      klass =
        Class.new(self) do
          mattr_accessor :preliminary

          def self.name
            "AssessorInterface::FurtherInformationRequestReviewForm"
          end
        end

      further_information_request.items.each do |item|
        klass.attribute "#{item.id}_decision"
        klass.validates "#{item.id}_decision",
                        inclusion: {
                          in:
                            FurtherInformationRequestItem.review_decisions.keys,
                          message:
                            "Select how you would like to respond to the applicant’s information",
                        }
      end

      klass
    end

    def initial_attributes(further_information_request)
      attributes = { further_information_request: }

      further_information_request.items.each do |item|
        attributes["#{item.id}_decision"] = item.review_decision
      end

      attributes
    end

    def permittable_parameters(further_information_request)
      further_information_request.items.map { |item| "#{item.id}_decision" }
    end
  end
end
