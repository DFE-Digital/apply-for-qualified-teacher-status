class CreateErrorLogValidationErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :error_log_validation_errors do |t|
      t.string :form_object, null: false
      t.json :messages, default: "{}", null: false
      t.references :record, polymorphic: true, null: false

      t.timestamps
    end

    add_index :error_log_validation_errors, :messages, using: :gin
  end
end
