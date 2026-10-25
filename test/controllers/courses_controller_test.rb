require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  test "anyone can see the courses list" do
    get courses_path
    assert_response :success
    assert_select "h3", text: courses(:calculus).title
  end

  test "anyone can open a course page" do
    course = courses(:calculus)
    get course_path(course)
    assert_response :success
    assert_select "h1", text: course.title
    assert_select "a[href=?]", teacher_path(course.teacher)
  end

  test "guest sees a login hint instead of the review form" do
    get course_path(courses(:calculus))
    assert_select "form[action=?]", reviews_path, count: 0
    assert_select "a[href=?]", new_session_path
  end

  test "logged in user can leave a review on a course" do
    post session_path, params: { session: { email: users(:alice).email, password: "secret123" } }
    course = courses(:calculus)

    assert_difference "course.reviews.count", 1 do
      post reviews_path, params: { review: { course_id: course.id, rating: 5, difficulty: 3, body: "Очень понятные лекции и задачи." } }
    end

    assert_redirected_to course_path(course)
    assert_equal course.teacher, course.reviews.last.teacher
    assert_equal "Hard", course.reviews.last.difficulty_label
    assert_equal "Hard", course.difficulty_label
  end

  test "invalid course review re-renders the course page" do
    post session_path, params: { session: { email: users(:alice).email, password: "secret123" } }
    course = courses(:calculus)

    assert_no_difference "Review.count" do
      post reviews_path, params: { review: { course_id: course.id, rating: 5, body: "коротко" } }
    end

    assert_response :unprocessable_entity
    assert_select "h1", text: course.title
  end
end
