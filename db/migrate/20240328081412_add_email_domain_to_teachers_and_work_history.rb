class AddEmailDomainToTeachersAndWorkHistory < ActiveRecord::Migration[7.1]
  def change
    change_table :teachers, bulk: true do |t|
      t.change_default :email, from: "", to: nil
      t.text :email_domain, default: "", null: false
    end

    add_column :work_histories,
               :contact_email_domain,
               :text,
               default: "",
               null: false
  end
end
