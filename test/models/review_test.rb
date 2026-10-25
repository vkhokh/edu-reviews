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
end
