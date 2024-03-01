# frozen_string_literal: true

class TeacherInterface::TeachingQualificationPartOfDegreeForm < TeacherInterface::BaseForm
  attr_accessor :application_form
  validates :application_form, presence: true

  attribute :teaching_qualification_part_of_degree, :boolean
  validates :teaching_qualification_part_of_degree,
            inclusion: {
              in: [true, false],
            }

  def update_model
    application_form.update!(teaching_qualification_part_of_degree:)
  end
end
