class AddDifficultyToReviews < ActiveRecord::Migration[8.1]
  def change
    add_column :reviews, :difficulty, :integer
  end
end
