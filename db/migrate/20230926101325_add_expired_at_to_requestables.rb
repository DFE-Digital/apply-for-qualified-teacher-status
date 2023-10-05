class AddExpiredAtToRequestables < ActiveRecord::Migration[7.0]
  def change
    add_column :further_information_requests, :expired_at, :datetime
    add_column :professional_standing_requests, :expired_at, :datetime
    add_column :qualification_requests, :expired_at, :datetime
    add_column :reference_requests, :expired_at, :datetime
  end
end
