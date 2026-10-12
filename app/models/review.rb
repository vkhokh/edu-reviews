# == Отзыв ==
# Happy path: залогиненный пользователь оставляет один отзыв о преподавателе —
# общая оценка (1-5) и текстовый комментарий. Модерация (README) — следующая
# итерация, пока отзыв считается опубликованным сразу после сохранения.
class Review < ApplicationRecord
  belongs_to :user
  belongs_to :teacher

  RATINGS = (1..5)

  validates :rating, presence: true, inclusion: { in: RATINGS, message: "должна быть от 1 до 5" }
  validates :body, presence: true, length: { minimum: 10, maximum: 2000 }
end
