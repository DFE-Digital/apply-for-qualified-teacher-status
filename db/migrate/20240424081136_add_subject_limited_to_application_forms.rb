class AddSubjectLimitedToApplicationForms < ActiveRecord::Migration[7.1]
  def change
    add_column :application_forms,
               :subject_limited,
               :boolean,
               null: false,
               default: false

    ApplicationForm
      .joins(:region)
      .where(region: { country: Country.where(subject_limited: true) })
      .update_all(subject_limited: true)
  end
end
