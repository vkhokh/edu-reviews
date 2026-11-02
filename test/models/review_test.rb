require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  def valid_attributes
    { user: users(:alice), teacher: teachers(:abramyan), rating: 5,
      body: "Отличный преподаватель, материал объясняет очень понятно." }
  end

  # --- Валидации ---

  test "валиден с корректными данными" do
    review = Review.new(valid_attributes)
    assert review.valid?
  end

  test "невалиден без оценки" do
    review = Review.new(valid_attributes.merge(rating: nil))
    assert_not review.valid?
    assert_includes review.errors[:rating], "должна быть от 1 до 5"
  end

  test "невалиден с оценкой вне диапазона 1..5" do
    review = Review.new(valid_attributes.merge(rating: 6))
    assert_not review.valid?
    assert_includes review.errors[:rating], "должна быть от 1 до 5"
  end

  test "невалиден с текстом короче 10 символов" do
    review = Review.new(valid_attributes.merge(body: "Коротко"))
    assert_not review.valid?
  end

  test "невалиден без текста" do
    review = Review.new(valid_attributes.merge(body: ""))
    assert_not review.valid?
  end

  # --- Ассоциации ---

  test "belongs_to user и teacher" do
    review = Review.create!(valid_attributes)
    assert_equal users(:alice), review.user
    assert_equal teachers(:abramyan), review.teacher
  end

  test "недействителен без пользователя" do
    review = Review.new(valid_attributes.merge(user: nil))
    assert_not review.valid?
  end

  test "недействителен без преподавателя" do
    review = Review.new(valid_attributes.merge(teacher: nil))
    assert_not review.valid?
  end

  # --- Сложность курса ---

  test "для отзыва о курсе сложность обязательна" do
    review = Review.new(user: users(:alice), teacher: teachers(:abramyan), course: courses(:calculus),
                        rating: 4, body: "Хороший курс, много практики.")
    assert_not review.valid?
    assert_includes review.errors[:difficulty], "нужно выбрать"

    review.difficulty = 2
    assert review.valid?
  end

  test "сложность вне списка недопустима" do
    review = Review.new(user: users(:alice), teacher: teachers(:abramyan), rating: 4,
                        body: "Хороший преподаватель.", difficulty: 9)
    assert_not review.valid?
  end

  test "отзыв о преподавателе без курса не требует сложности" do
    review = Review.new(user: users(:alice), teacher: teachers(:abramyan), rating: 4,
                        body: "Хороший преподаватель.")
    assert review.valid?
  end

  # --- Один отзыв на курс и на преподавателя ---

  test "второй отзыв того же пользователя о том же курсе недопустим" do
    skip "ограничение «один отзыв» отключено в app/models/review.rb" unless Review.one_per_user?
    attrs = { user: users(:alice), teacher: teachers(:abramyan), course: courses(:calculus),
              rating: 5, difficulty: 2, body: "Первый отзыв о курсе, всё понравилось." }
    Review.create!(attrs)

    second = Review.new(attrs.merge(body: "Второй отзыв о том же курсе."))
    assert_not second.valid?
    assert_includes second.errors[:base], "Вы уже оставили отзыв об этом курсе"
  end

  test "второй отзыв того же пользователя о преподавателе недопустим" do
    skip "ограничение «один отзыв» отключено в app/models/review.rb" unless Review.one_per_user?
    Review.create!(valid_attributes)

    second = Review.new(valid_attributes.merge(body: "Ещё один отзыв о том же преподавателе."))
    assert_not second.valid?
    assert_includes second.errors[:base], "Вы уже оставили отзыв об этом преподавателе"
  end

  test "другой пользователь может оставить отзыв о том же курсе" do
    attrs = { teacher: teachers(:abramyan), course: courses(:calculus), rating: 5, difficulty: 2,
              body: "Хороший курс, много практики." }
    Review.create!(attrs.merge(user: users(:alice)))
    assert Review.new(attrs.merge(user: users(:bob))).valid?
  end

  test "отзыв о курсе не мешает отзыву о его преподавателе" do
    Review.create!(user: users(:alice), teacher: teachers(:abramyan), course: courses(:calculus),
                   rating: 5, difficulty: 2, body: "Отзыв о курсе преподавателя.")
    assert Review.new(valid_attributes).valid?
  end
end
