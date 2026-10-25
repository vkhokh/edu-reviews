class AddCourseToReviews < ActiveRecord::Migration[8.1]
  def change
    add_reference :reviews, :course, null: true, foreign_key: true
  end
end
