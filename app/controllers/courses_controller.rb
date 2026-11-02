class CoursesController < ApplicationController
  def index
    @courses = Course.includes(:teacher).order(:title)
  end

  def show
    @course = Course.find(params[:id])
    @reviews = @course.reviews.includes(:user).order(created_at: :desc)
    @review = Review.new
    # Отзыв текущего пользователя об этом курсе, если он уже есть
    @my_review = current_user&.reviews&.find_by(course: @course) if Review.one_per_user?
  end
end
