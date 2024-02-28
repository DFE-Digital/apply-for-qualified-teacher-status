# frozen_string_literal: true

module TeacherInterface
  class PartOfUniversityDegreeForm < BaseForm
    attr_accessor :qualification
    validates :qualification, presence: true

    attribute :part_of_university_degree, :boolean
    validates :part_of_university_degree, inclusion: { in: [true, false] }

    def update_model
      qualification.update!(part_of_university_degree:)
      application_form.update!(
        teaching_qualification_part_of_degree: part_of_university_degree,
      )
    end

    delegate :application_form, to: :qualification
  end
end
