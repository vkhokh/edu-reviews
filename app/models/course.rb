# == Курс ==
# Учебный предмет, который ведёт преподаватель.
class Course < ApplicationRecord
  belongs_to :teacher
  has_many :reviews, dependent: :destroy

  validates :title, presence: true, length: { maximum: 150 }
  validates :description, presence: true, length: { maximum: 2000 }

  # Средняя сложность по отзывам, округлённая до уровня (nil, если оценок нет).
  def difficulty_label
    avg = reviews.where.not(difficulty: nil).average(:difficulty)
    Review::DIFFICULTIES[avg.round] if avg
  end

  def average_rating
    reviews.average(:rating)&.round(1)
  end
end
