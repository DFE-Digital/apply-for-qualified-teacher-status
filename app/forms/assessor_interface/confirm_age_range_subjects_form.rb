# frozen_string_literal: true

class AssessorInterface::ConfirmAgeRangeSubjectsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  include AssessorInterface::AgeRangeSubjectsForm

  attr_accessor :assessment, :user
  validates :assessment, :user, presence: true
end
