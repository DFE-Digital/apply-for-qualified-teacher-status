class RemoveStatusFromApplicationForms < ActiveRecord::Migration[7.0]
  def change
    change_table :application_forms, bulk: true do |t|
      t.remove :status, type: :string, null: false, default: "draft"
      t.remove :overdue_further_information,
               type: :boolean,
               default: false,
               null: false
      t.remove :overdue_professional_standing,
               type: :boolean,
               default: false,
               null: false
      t.remove :overdue_qualification,
               type: :boolean,
               default: false,
               null: false
      t.remove :overdue_reference, type: :boolean, default: false, null: false
      t.remove :received_further_information,
               type: :boolean,
               default: false,
               null: false
      t.remove :received_professional_standing,
               type: :boolean,
               default: false,
               null: false
      t.remove :received_qualification,
               type: :boolean,
               default: false,
               null: false
      t.remove :received_reference, type: :boolean, default: false, null: false
      t.remove :waiting_on_further_information,
               type: :boolean,
               default: false,
               null: false
      t.remove :waiting_on_professional_standing,
               type: :boolean,
               default: false,
               null: false
      t.remove :waiting_on_qualification,
               type: :boolean,
               default: false,
               null: false
      t.remove :waiting_on_reference,
               type: :boolean,
               default: false,
               null: false
    end
  end
end
