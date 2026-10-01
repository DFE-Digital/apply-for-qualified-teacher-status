# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionFilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :submitted_at_after, :submitted_at_before

  validates :submitted_at_after, date: true, allow_blank: true
  validates :submitted_at_before, date: true, allow_blank: true
  validates_with DateComparisonValidator,
                 earlier_field: :submitted_at_after,
                 later_field: :submitted_at_before,
                 allow_equal: true
end
