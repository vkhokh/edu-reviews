require "test_helper"

# КТ 8: живое и частичное обновление страниц (Action Cable + Turbo Streams + Turbo Frames).
class LiveUpdatesTest < ActionDispatch::IntegrationTest
  include Turbo::Broadcastable::TestHelper

  # Заголовок Accept, который отправляет Turbo при отправке формы в браузере
  TURBO_ACCEPT = "text/vnd.turbo-stream.html, text/html, application/xhtml+xml".freeze

  def course_review_params(course, body: "Отличный курс, всё объясняют очень понятно.")
    { review: { course_id: course.id, rating: 5, difficulty: 3, body: body } }
  end

  # --- Подписка на обновления ---

  test "страницы курса и преподавателя подписываются на свои каналы" do
    course = courses(:calculus)

    get course_path(course)
    assert_select "turbo-cable-stream-source"

    get teacher_path(course.teacher)
    assert_select "turbo-cable-stream-source"
  end

  test "форма отзыва лежит в Turbo Frame" do
    log_in_as users(:alice)
    get course_path(courses(:calculus))
    assert_select "turbo-frame#new_review form[action=?]", reviews_path
  end

  # --- Рассылка через Action Cable ---

  test "новый отзыв рассылается всем, кто смотрит курс и преподавателя" do
    course = courses(:calculus)
    log_in_as users(:alice)

    post reviews_path, params: course_review_params(course)

    # курс: убрать «пока нет отзывов», добавить отзыв, обновить оценку и сложность
    assert_turbo_stream_broadcasts course, count: 4
    # преподаватель: убрать «пока нет отзывов», добавить отзыв, обновить оценку
    assert_turbo_stream_broadcasts course.teacher, count: 3

    actions = capture_turbo_stream_broadcasts(course).map { |stream| [stream["action"], stream["target"]] }
    assert_includes actions, ["prepend", "reviews_list"]
    assert_includes actions, ["replace", "course_rating"]
  end

  test "отзыв о преподавателе без курса рассылается только на страницу преподавателя" do
    teacher = teachers(:kozak)
    log_in_as users(:alice)

    post reviews_path, params: { from: "teacher",
                                 review: { teacher_id: teacher.id, rating: 4, body: "Строгий, но справедливый." } }

    assert_turbo_stream_broadcasts teacher, count: 3
  end

  test "невалидный отзыв ничего не рассылает" do
    course = courses(:calculus)
    log_in_as users(:alice)

    post reviews_path, params: course_review_params(course, body: "коротко")

    assert_no_turbo_stream_broadcasts course
    assert_no_turbo_stream_broadcasts course.teacher
  end

  # --- Ответ автору: частичное обновление без перезагрузки ---

  test "автор получает Turbo Stream: новая форма, flash, отзыв в списке, оценка" do
    course = courses(:calculus)
    log_in_as users(:alice)

    post reviews_path, params: course_review_params(course), headers: { "Accept" => TURBO_ACCEPT }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action=replace][target=new_review]"
    assert_select "turbo-stream[action=update][target=flash]"
    assert_select "turbo-stream[action=prepend][target=reviews_list]"
    assert_select "turbo-stream[action=replace][target=course_rating]"
  end

  test "ошибка в форме обновляет только Turbo Frame с формой" do
    course = courses(:calculus)
    log_in_as users(:alice)

    assert_no_difference "Review.count" do
      post reviews_path, params: course_review_params(course, body: "коротко"), headers: { "Accept" => TURBO_ACCEPT }
    end

    assert_response :unprocessable_entity
    assert_select "turbo-frame#new_review .auth-errors li"
  end

  test "обычная отправка без Turbo по-прежнему делает редирект" do
    course = courses(:calculus)
    log_in_as users(:alice)

    post reviews_path, params: course_review_params(course)
    assert_redirected_to course_path(course)
  end
end
