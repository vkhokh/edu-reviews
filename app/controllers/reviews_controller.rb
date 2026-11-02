class ReviewsController < ApplicationController
  before_action :require_login

  def new
    @review = Review.new
    @teachers = Teacher.order(:name)
  end

  def create
    @review = current_user.reviews.build(review_params)
    # Отзыв о курсе: преподавателя берём у курса, а не из формы.
    @review.teacher = @review.course.teacher if @review.course

    if @review.save
      respond_to do |format|
        # Форма на странице курса/преподавателя: обновляем только части страницы
        format.turbo_stream { render_saved_review_streams } if inline_form?
        format.html { redirect_to after_create_path, notice: "Спасибо! Ваш отзыв сохранён." }
      end
    elsif @review.course
      @course = @review.course
      @reviews = @course.reviews.includes(:user).order(created_at: :desc)
      render "courses/show", status: :unprocessable_entity
    elsif from_teacher_page? && @review.teacher
      @teacher = @review.teacher
      @reviews = @teacher.reviews.includes(:user, :course).order(created_at: :desc)
      render "teachers/show", status: :unprocessable_entity
    else
      @teachers = Teacher.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Отзыв отправлен с формы на странице курса или преподавателя (а не с /reviews/new)
  def inline_form?
    @review.course.present? || from_teacher_page?
  end

  # Ответ на успешную отправку: вместо формы — «вы уже оставили отзыв», flash, новый отзыв в списке и новая оценка.
  # Остальным зрителям страницы то же самое приходит через Action Cable (Review#broadcast_to_pages).
  def render_saved_review_streams
    flash.now[:notice] = "Спасибо! Ваш отзыв сохранён."
    streams = [
      turbo_stream.update("flash", partial: "layouts/flash"),
      turbo_stream.remove("reviews_empty")
    ]

    if @review.course
      course = @review.course
      streams += [
        new_review_form_stream(partial: "courses/review_form", locals: { review: Review.new, course: course }, about: "этом курсе"),
        turbo_stream.prepend("reviews_list", partial: "reviews/review", locals: { review: @review, show_course: false }),
        turbo_stream.replace("course_rating", partial: "courses/rating", locals: { course: course }),
        turbo_stream.replace("course_difficulty", partial: "courses/difficulty", locals: { course: course })
      ]
    else
      teacher = @review.teacher
      streams += [
        new_review_form_stream(partial: "teachers/review_form", locals: { review: Review.new, teacher: teacher }, about: "этом преподавателе"),
        turbo_stream.prepend("reviews_list", partial: "reviews/review", locals: { review: @review, show_course: true }),
        turbo_stream.replace("teacher_rating", partial: "teachers/rating", locals: { teacher: teacher })
      ]
    end

    render turbo_stream: streams
  end

  # Что показать на месте формы: «вы уже оставили отзыв» или (если ограничение отключено) пустую форму
  def new_review_form_stream(partial:, locals:, about:)
    if Review.one_per_user?
      turbo_stream.replace("new_review", partial: "reviews/already_reviewed", locals: { review: @review, about: about })
    else
      turbo_stream.replace("new_review", partial: partial, locals: locals)
    end
  end

  def after_create_path
    if @review.course
      course_path(@review.course)
    elsif from_teacher_page?
      teacher_path(@review.teacher)
    else
      root_path
    end
  end

  # Форма на странице преподавателя присылает скрытое поле from=teacher.
  def from_teacher_page?
    params[:from] == "teacher"
  end

  def review_params
    params.require(:review).permit(:teacher_id, :course_id, :difficulty, :rating, :body)
  end
end
