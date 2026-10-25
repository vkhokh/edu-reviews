require "test_helper"

# Ответвления от happy path: что происходит, когда что-то идёт не так.
class ReviewBranchesTest < ActionDispatch::IntegrationTest
  # Ветка 1. Нет прав: гость пытается оставить отзыв.
  test "гость не может открыть форму отзыва и отправить отзыв" do
    get new_review_path
    assert_redirected_to new_session_path
    follow_redirect!
    assert_select ".flash-alert", text: /Сначала войдите в аккаунт/

    assert_no_difference "Review.count" do
      post reviews_path, params: { review: { course_id: courses(:calculus).id, rating: 5, difficulty: 2,
                                             body: "Попытка оставить отзыв без входа." } }
    end
    assert_redirected_to new_session_path
  end

  test "гость не может добавить преподавателя" do
    assert_no_difference "Teacher.count" do
      post teachers_path, params: { teacher: { name: "Самозванец С. С.", department: "Мехмат" } }
    end
    assert_redirected_to new_session_path
  end

  # Ветка 2. Ошибка ввода: отзыв не проходит проверки.
  test "слишком короткий отзыв не сохраняется и показывает ошибки" do
    course = courses(:calculus)
    log_in_as users(:alice)

    assert_no_difference "Review.count" do
      post reviews_path, params: { review: { course_id: course.id, rating: 5, difficulty: 2, body: "коротко" } }
    end

    assert_response :unprocessable_entity
    assert_select "h1", text: course.title
    assert_select ".auth-errors li"
    assert_select "textarea", text: /коротко/ # введённый текст не пропал
  end

  test "отзыв о курсе без сложности не сохраняется" do
    course = courses(:calculus)
    log_in_as users(:alice)

    assert_no_difference "Review.count" do
      post reviews_path, params: { review: { course_id: course.id, rating: 5,
                                             body: "Хороший курс, но сложность не указана." } }
    end
    assert_response :unprocessable_entity
    assert_select ".auth-errors li", text: /нужно выбрать/
  end

  # Ветка 3. Подмена данных: преподавателя берём у курса, а не из формы.
  test "преподаватель отзыва о курсе определяется курсом, а не формой" do
    course = courses(:calculus)   # ведёт abramyan
    other = teachers(:kozak)
    log_in_as users(:alice)

    post reviews_path, params: { review: { course_id: course.id, teacher_id: other.id, rating: 5, difficulty: 2,
                                           body: "Пробуем подменить преподавателя в форме." } }

    assert_equal course.teacher, course.reviews.last.teacher
    assert_not_equal other, course.reviews.last.teacher
  end

  # Ветка 4. Вход и регистрация с ошибками.
  test "неверный пароль не пускает, и отзыв оставить нельзя" do
    log_in_as users(:alice), password: "wrong-password"
    assert_response :unprocessable_entity
    assert_select ".flash-alert", text: /Неверная почта или пароль/

    get new_review_path
    assert_redirected_to new_session_path
  end

  test "регистрация с коротким паролем отклоняется" do
    assert_no_difference "User.count" do
      post registration_path, params: { user: { name: "Новый", email: "short@example.com",
                                                password: "123", password_confirmation: "123" } }
    end
    assert_response :unprocessable_entity
  end

  test "регистрация с уже занятой почтой отклоняется" do
    assert_no_difference "User.count" do
      post registration_path, params: { user: { name: "Двойник", email: users(:alice).email.upcase,
                                                password: "secret123", password_confirmation: "secret123" } }
    end
    assert_response :unprocessable_entity
  end
end
