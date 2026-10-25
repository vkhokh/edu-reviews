require "test_helper"

class TeacherTest < ActiveSupport::TestCase
  # --- Валидации ---

  test "валиден с именем и кафедрой" do
    teacher = Teacher.new(name: "Сидоров С. С.", department: "Мехмат")
    assert teacher.valid?
  end

  test "невалиден без имени" do
    teacher = Teacher.new(department: "Мехмат")
    assert_not teacher.valid?
    assert_includes teacher.errors[:name], "can't be blank"
  end

  test "невалиден без кафедры" do
    teacher = Teacher.new(name: "Сидоров С. С.")
    assert_not teacher.valid?
    assert_includes teacher.errors[:department], "can't be blank"
  end

  # --- Ассоциации ---

  test "has_many reviews с dependent destroy" do
    teacher = teachers(:abramyan)
    teacher.reviews.create!(user: users(:alice), rating: 4,
                             body: "Хорошо объясняет материал, но строгий на экзамене.")

    assert_difference("Review.count", -1) do
      teacher.destroy
    end
  end

  # --- Бизнес-логика: average_rating ---

  test "average_rating равен nil, если отзывов ещё нет" do
    teacher = teachers(:kozak)
    assert_nil teacher.average_rating
  end

  test "average_rating считает среднее по всем отзывам" do
    teacher = teachers(:kozak)
    teacher.reviews.create!(user: users(:alice), rating: 5, body: "Очень понравился курс и подача материала.")
    teacher.reviews.create!(user: users(:bob), rating: 3, body: "Нормально, но местами скучно и сухо.")

    assert_equal 4.0, teacher.average_rating
  end

  test "average_rating округляет до одного знака после запятой" do
    teacher = teachers(:kozak)
    teacher.reviews.create!(user: users(:alice), rating: 5, body: "Очень понравился курс и подача материала.")
    teacher.reviews.create!(user: users(:bob), rating: 4, body: "Хороший преподаватель, но много заданий.")

    assert_equal 4.5, teacher.average_rating
  end

  test "has_many courses с dependent destroy" do
    teacher = teachers(:abramyan)
    assert_difference("Course.count", -1) do
      teacher.destroy
    end
  end
end
