class AddTeachingQualificationPartOfDegreeToApplicationForms < ActiveRecord::Migration[
  7.1
]
  def change
    add_column :application_forms,
               :teaching_qualification_part_of_degree,
               :boolean

    ApplicationForm
      .includes(:qualifications)
      .find_each do |application_form|
        application_form.update!(
          teaching_qualification_part_of_degree:
            application_form.teaching_qualification&.part_of_university_degree,
        )
      end
  end
end
