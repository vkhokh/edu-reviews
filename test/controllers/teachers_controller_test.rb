require "test_helper"

class TeachersControllerTest < ActionDispatch::IntegrationTest
  def log_in
    post session_path, params: { session: { email: users(:alice).email, password: "secret123" } }
  end

  test "anyone can see the teachers list" do
    get teachers_path
    assert_response :success
    assert_select "h3", text: teachers(:abramyan).name
  end

  test "anyone can open a teacher page with reviews" do
    teacher = teachers(:abramyan)
    teacher.reviews.create!(user: users(:alice), rating: 5, body: "Отличный преподаватель, всё понятно")

    get teacher_path(teacher)

    assert_response :success
    assert_select "h1", text: teacher.name
    assert_select "p", text: /Отличный преподаватель/
  end

  test "teacher page without reviews shows a hint" do
    get teacher_path(teachers(:kozak))
    assert_response :success
    assert_select "p", text: /Пока нет отзывов/
  end

  test "guest is redirected to login" do
    get new_teacher_path
    assert_redirected_to new_session_path
  end

  test "guest cannot create a teacher" do
    assert_no_difference "Teacher.count" do
      post teachers_path, params: { teacher: { name: "Иванов И. И.", department: "Мехмат" } }
    end
    assert_redirected_to new_session_path
  end

  test "logged in user can create a teacher" do
    log_in
    assert_difference "Teacher.count", 1 do
      post teachers_path, params: { teacher: { name: "Иванов И. И.", department: "Мехмат" } }
    end
    assert_redirected_to new_review_path
  end

  test "invalid teacher is not saved" do
    log_in
    assert_no_difference "Teacher.count" do
      post teachers_path, params: { teacher: { name: "", department: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "guest sees a login hint instead of the review form on teacher page" do
    get teacher_path(teachers(:abramyan))
    assert_select "form[action=?]", reviews_path, count: 0
    assert_select "a[href=?]", new_session_path
  end

  test "logged in user can leave a review on teacher page" do
    log_in
    teacher = teachers(:abramyan)

    assert_difference "teacher.reviews.count", 1 do
      post reviews_path, params: { from: "teacher", review: { teacher_id: teacher.id, rating: 4, body: "Строгий, но справедливый." } }
    end
    assert_redirected_to teacher_path(teacher)
  end

  test "invalid review on teacher page re-renders it" do
    log_in
    teacher = teachers(:abramyan)

    assert_no_difference "Review.count" do
      post reviews_path, params: { from: "teacher", review: { teacher_id: teacher.id, rating: 4, body: "коротко" } }
    end
    assert_response :unprocessable_entity
    assert_select "h1", text: teacher.name
  end
end
