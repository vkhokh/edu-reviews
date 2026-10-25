require "test_helper"

class CourseTest < ActiveSupport::TestCase
  test "валиден с названием, описанием и преподавателем" do
    course = Course.new(title: "Алгебра", description: "Линейная алгебра.", teacher: teachers(:abramyan))
    assert course.valid?
  end

  test "невалиден без названия" do
    course = Course.new(description: "Описание", teacher: teachers(:abramyan))
    assert_not course.valid?
    assert_includes course.errors[:title], "can't be blank"
  end

  test "невалиден без описания" do
    course = Course.new(title: "Алгебра", teacher: teachers(:abramyan))
    assert_not course.valid?
    assert_includes course.errors[:description], "can't be blank"
  end

  test "невалиден без преподавателя" do
    course = Course.new(title: "Алгебра", description: "Описание")
    assert_not course.valid?
  end
end
