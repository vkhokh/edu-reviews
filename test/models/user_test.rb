require "test_helper"

class UserTest < ActiveSupport::TestCase
  # --- Валидации ---

  test "валиден с корректными данными" do
    user = User.new(name: "Иван Иванов", email: "ivan@example.com", password: "secret123")
    assert user.valid?
  end

  test "невалиден без имени" do
    user = User.new(email: "ivan@example.com", password: "secret123")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "невалиден с некорректным email" do
    user = User.new(name: "Иван", email: "not-an-email", password: "secret123")
    assert_not user.valid?
    assert_includes user.errors[:email], "имеет неверный формат"
  end

  test "невалиден с уже занятым email (без учёта регистра)" do
    user = User.new(name: "Дубликат", email: users(:alice).email.upcase, password: "secret123")
    assert_not user.valid?
  end

  test "невалиден с паролем короче 6 символов" do
    user = User.new(name: "Иван", email: "ivan2@example.com", password: "123")
    assert_not user.valid?
  end

  # --- Поведение модели ---

  test "email приводится к нижнему регистру перед сохранением" do
    user = User.create!(name: "Пётр", email: "PETR@EXAMPLE.COM", password: "secret123")
    assert_equal "petr@example.com", user.reload.email
  end

  # --- Ассоциации ---

  test "has_many reviews с dependent destroy" do
    user = users(:alice)
    user.reviews.create!(teacher: teachers(:abramyan), rating: 5,
                          body: "Отличный преподаватель, всё понятно объясняет.")

    assert_difference("Review.count", -1) do
      user.destroy
    end
  end
end
