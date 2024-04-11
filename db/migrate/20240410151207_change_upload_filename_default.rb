class ChangeUploadFilenameDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :uploads, :filename, from: "", to: nil
  end
end
