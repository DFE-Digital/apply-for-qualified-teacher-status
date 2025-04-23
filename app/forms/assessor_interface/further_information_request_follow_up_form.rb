# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestFollowUpForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :further_information_request, :user
  validates :further_information_request, :user, presence: true

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      further_information_request
        .items
        .review_decision_further_information
        .each do |item|
        review_decision_note = send("#{item.id}_decision_note")

        item.update!(review_decision_note:)
      end
    end

    true
  end

  class << self
    def for_further_information_request(further_information_request)
      klass =
        Class.new(self) do
          mattr_accessor :preliminary

          def self.name
            "AssessorInterface::FurtherInformationRequestFollowUpForm"
          end
        end

      further_information_request
        .items
        .review_decision_further_information
        .each do |item|
        klass.attribute "#{item.id}_decision_note"
        klass.validates "#{item.id}_decision_note",
                        presence: {
                          message: "Enter instructions for the applicant",
                        }
      end

      klass
    end

    def initial_attributes(further_information_request)
      attributes = { further_information_request: }

      further_information_request
        .items
        .review_decision_further_information
        .each do |item|
        attributes["#{item.id}_decision_note"] = item.review_decision_note
      end

      attributes
    end

    def permittable_parameters(further_information_request)
      further_information_request
        .items
        .review_decision_further_information
        .map { |item| "#{item.id}_decision_note" }
    end
  end
end
