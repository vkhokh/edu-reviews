class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.references :teacher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
