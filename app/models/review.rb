# == Отзыв ==
# Happy path: залогиненный пользователь оставляет один отзыв о преподавателе —
# общая оценка (1-5) и текстовый комментарий. Модерация (README) — следующая
# итерация, пока отзыв считается опубликованным сразу после сохранения.
class Review < ApplicationRecord
  belongs_to :user
  belongs_to :teacher
  # Курс необязателен: старые отзывы относятся только к преподавателю.
  belongs_to :course, optional: true

  RATINGS = (1..5)

  # Уровень сложности курса (оставляется только в отзыве о курсе).
  DIFFICULTIES = { 1 => "Easy", 2 => "Medium", 3 => "Hard", 4 => "Extra hard" }.freeze

  validates :difficulty, inclusion: { in: DIFFICULTIES.keys, message: "выберите из списка" }, allow_nil: true
  validates :difficulty, presence: { message: "нужно выбрать" }, if: :course

  def difficulty_label
    DIFFICULTIES[difficulty]
  end

  validates :rating, presence: true, inclusion: { in: RATINGS, message: "должна быть от 1 до 5" }
  validates :body, presence: true, length: { minimum: 10, maximum: 2000 }
end
