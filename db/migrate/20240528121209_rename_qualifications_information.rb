class RenameQualificationsInformation < ActiveRecord::Migration[7.1]
  def change
    rename_column :countries,
                  :qualifications_information,
                  :teaching_qualification_information
    rename_column :regions,
                  :qualifications_information,
                  :teaching_qualification_information
  end
end
