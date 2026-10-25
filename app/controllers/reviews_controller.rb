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
      redirect_to after_create_path, notice: "Спасибо! Ваш отзыв сохранён."
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
