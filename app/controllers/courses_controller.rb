class CoursesController < ApplicationController
  def index
    @courses = Course.includes(:teacher).order(:title)
  end

  def show
    @course = Course.find(params[:id])
    @reviews = @course.reviews.includes(:user).order(created_at: :desc)
    @review = Review.new
  end
end
