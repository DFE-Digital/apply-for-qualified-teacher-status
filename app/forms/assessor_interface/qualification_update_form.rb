# frozen_string_literal: true

class AssessorInterface::QualificationUpdateForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :qualification, :user
  attribute :certificate_date, :date
  attribute :complete_date, :date
  attribute :start_date, :date

  attribute :institution_country_code, :string
  attribute :institution_name, :string
  attribute :title, :string

  attribute :teaching_qualification_part_of_degree, :boolean

  validates :qualification, :user, presence: true

  def save
    # TODO
  end
end
