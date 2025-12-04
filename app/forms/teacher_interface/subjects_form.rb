# frozen_string_literal: true

class TeacherInterface::SubjectsForm < TeacherInterface::BaseForm
  attr_accessor :application_form
  attribute :subject_1, :string
  attribute :subject_2, :string
  attribute :subject_3, :string

  validates :application_form, presence: true
  validates :subject_1, presence: true, string_length: true
  validates :subject_2, :subject_3, string_length: true

  def update_model
    application_form.update!(subjects:)
  end

  private

  def subjects
    [subject_1, subject_2, subject_3].compact_blank
  end
end
