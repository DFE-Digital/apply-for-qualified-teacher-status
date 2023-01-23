class AddPotentialDuplicateToDQTTRNRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :dqt_trn_requests, :potential_duplicate, :boolean
  end
end
