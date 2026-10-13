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
end
