class CreateTeachers < ActiveRecord::Migration[8.1]
  def change
    create_table :teachers do |t|
      t.string :name, null: false
      t.string :department, null: false

      t.timestamps
    end
  end
end
