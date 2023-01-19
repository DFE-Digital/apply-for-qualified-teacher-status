class RemoveApplicationFormFurtherInformationStates < ActiveRecord::Migration[
  7.0
]
  def change
    ApplicationForm.where(state: "further_information_requested").update_all(
      state: "waiting_on",
    )
    ApplicationForm.where(state: "further_information_received").update_all(
      state: "received",
    )
  end
end
