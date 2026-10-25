require "test_helper"

# Интеграционные тесты happy path: новый студент проходит весь путь
# от регистрации до отзыва, и этот отзыв виден на сайте.
class ReviewHappyPathTest < ActionDispatch::IntegrationTest
  test "новый пользователь регистрируется и оставляет отзыв о курсе" do
    course = courses(:calculus)

    # 1. Регистрация
    assert_difference "User.count", 1 do
      post registration_path, params: { user: { name: "Новый Студент", email: "new@example.com",
                                                password: "secret123", password_confirmation: "secret123" } }
    end
    assert_redirected_to root_path
    follow_redirect!
    assert_select ".flash-notice", text: /Добро пожаловать, Новый Студент/

    # 2. Главная ведёт на курс по клику на карточку
    assert_select "a[href=?]", course_path(course), text: course.title

    # 3. Страница курса: у вошедшего есть форма отзыва
    get course_path(course)
    assert_response :success
    assert_select "h1", text: course.title
    assert_select "form[action=?]", reviews_path

    # 4. Отправка отзыва
    assert_difference "course.reviews.count", 1 do
      post reviews_path, params: { review: { course_id: course.id, rating: 5, difficulty: 3,
                                             body: "Отличный курс, всё объясняют очень понятно." } }
    end
    assert_redirected_to course_path(course)
    follow_redirect!

    # 5. Отзыв виден на странице курса вместе с оценкой и сложностью
    assert_select ".flash-notice", text: /Спасибо! Ваш отзыв сохранён/
    assert_select "p", text: /Отличный курс, всё объясняют/
    assert_select ".rating", text: /5\.0/
    assert_select ".tag", text: /Сложность: Hard/

    # 6. Отзыв автоматически привязан к преподавателю курса и виден на его странице
    review = course.reviews.last
    assert_equal course.teacher, review.teacher
    assert_equal User.find_by(email: "new@example.com"), review.user

    get teacher_path(course.teacher)
    assert_select "p", text: /Отличный курс, всё объясняют/
    assert_select ".badge", text: /Курс: #{course.title}/

    # 7. Каталог и главная показывают обновлённые данные
    get courses_path
    assert_select ".tag", text: /Hard/
    get root_path
    assert_select "a", text: /Отзывов: 1/
  end

  test "вошедший пользователь оставляет отзыв о преподавателе, а затем выходит" do
    teacher = teachers(:kozak)

    log_in_as users(:alice)
    assert_redirected_to root_path

    get teachers_path
    assert_select "h3 a[href=?]", teacher_path(teacher)

    get teacher_path(teacher)
    assert_select "form[action=?]", reviews_path

    assert_difference "teacher.reviews.count", 1 do
      post reviews_path, params: { from: "teacher",
                                   review: { teacher_id: teacher.id, rating: 4, body: "Строгий, но справедливый преподаватель." } }
    end
    assert_redirected_to teacher_path(teacher)
    follow_redirect!
    assert_select "p", text: /Строгий, но справедливый/
    assert_select ".rating", text: /4\.0/

    # Выход: после него форма отзыва снова недоступна
    delete session_path
    assert_redirected_to new_session_path
    get teacher_path(teacher)
    assert_select "form[action=?]", reviews_path, count: 0
  end
end
