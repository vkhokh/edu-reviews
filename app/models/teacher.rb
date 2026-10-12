# == Преподаватель ==
# Пока минимальная модель: достаточно, чтобы привязать к ней отзывы.
# Каталог курсов/преподавателей — отдельная будущая фича, сюда не входит.
class Teacher < ApplicationRecord
  has_many :reviews, dependent: :destroy

  validates :name, presence: true, length: { maximum: 150 }
  validates :department, presence: true, length: { maximum: 150 }

  def average_rating
    reviews.average(:rating)&.round(1)
  end
end
