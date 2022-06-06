class CreateExamples < ActiveRecord::Migration[7.0]
  def change
    create_table :examples, &:timestamps
  end
end
