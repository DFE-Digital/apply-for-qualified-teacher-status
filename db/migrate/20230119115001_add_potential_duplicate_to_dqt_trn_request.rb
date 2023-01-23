class AddPotentialDuplicateToDQTTRNRequest < ActiveRecord::Migration[7.0]
  def up
    add_column :dqt_trn_requests, :potential_duplicate, :boolean

    DQTTRNRequest.complete.update_all(potential_duplicate: false)

    ApplicationForm.potential_duplicate_in_dqt.each do |application_form|
      application_form.dqt_trn_request.update!(potential_duplicate: true)
    end
  end

  def down
    remove_column :dqt_trn_requests, :potential_duplicate
  end
end
