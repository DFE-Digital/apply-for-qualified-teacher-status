class UpdateApplicationformStatus < ActiveRecord::Migration[7.0]
  def change
    Applicationform.where(status: 'initial assessment').update_all(status: 'assessment in progress')
  end
end
