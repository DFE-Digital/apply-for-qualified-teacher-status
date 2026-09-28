# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionFilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :submitted_at_after, :submitted_at_before
end
