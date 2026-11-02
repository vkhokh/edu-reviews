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

  # ======================================================================
  # Один пользователь — один отзыв о курсе и один отзыв о преподавателе.
  # Чтобы ОТКЛЮЧИТЬ ограничение, закомментируйте ОДНУ строку ниже.
  # Страницы, контроллеры и тесты подстроятся сами через Review.one_per_user?
  validate :one_review_per_user
  # ======================================================================

  # true, если строка `validate :one_review_per_user` выше не закомментирована
  def self.one_per_user?
    _validate_callbacks.any? { |callback| callback.filter == :one_review_per_user }
  end

  validates :rating, presence: true, inclusion: { in: RATINGS, message: "должна быть от 1 до 5" }
  validates :body, presence: true, length: { minimum: 10, maximum: 2000 }

  # Живое обновление (КТ 8): после сохранения отзыва рассылаем Turbo Streams
  # через Action Cable всем, у кого открыта страница этого курса или преподавателя.
  after_create_commit :broadcast_to_pages

  private

  def one_review_per_user
    return unless user_id && teacher_id

    others = Review.where(user_id: user_id).where.not(id: id)
    if course_id
      errors.add(:base, "Вы уже оставили отзыв об этом курсе") if others.exists?(course_id: course_id)
    elsif others.exists?(teacher_id: teacher_id, course_id: nil)
      errors.add(:base, "Вы уже оставили отзыв об этом преподавателе")
    end
  end

  def broadcast_to_pages
    if course
      broadcast_remove_to course, target: "reviews_empty"
      broadcast_prepend_to course, target: "reviews_list",
                           partial: "reviews/review", locals: { review: self, show_course: false }
      broadcast_replace_to course, target: "course_rating",
                           partial: "courses/rating", locals: { course: course }
      broadcast_replace_to course, target: "course_difficulty",
                           partial: "courses/difficulty", locals: { course: course }
    end

    broadcast_remove_to teacher, target: "reviews_empty"
    broadcast_prepend_to teacher, target: "reviews_list",
                         partial: "reviews/review", locals: { review: self, show_course: true }
    broadcast_replace_to teacher, target: "teacher_rating",
                         partial: "teachers/rating", locals: { teacher: teacher }
  end
end
