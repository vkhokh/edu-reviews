class TeachersController < ApplicationController
  before_action :require_login, except: :index

  def index
    @teachers = Teacher.includes(:reviews).order(:name)
  end

  def new
    @teacher = Teacher.new
  end

  def create
    @teacher = Teacher.new(teacher_params)

    if @teacher.save
      redirect_to new_review_path, notice: "Преподаватель добавлен. Теперь можно оставить отзыв."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def teacher_params
    params.require(:teacher).permit(:name, :department)
  end
end
