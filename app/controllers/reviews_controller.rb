class ReviewsController < ApplicationController
  before_action :require_login

  def new
    @review = Review.new
    @teachers = Teacher.order(:name)
  end

  def create
    @review = current_user.reviews.build(review_params)
    @teachers = Teacher.order(:name)

    if @review.save
      redirect_to root_path, notice: "Спасибо! Ваш отзыв сохранён."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(:teacher_id, :rating, :body)
  end
end
