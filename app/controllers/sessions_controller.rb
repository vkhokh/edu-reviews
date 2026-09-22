class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params.dig(:session, :email).to_s.strip.downcase)

    if user&.authenticate(params.dig(:session, :password))
      session[:user_id] = user.id
      redirect_to root_path, notice: "С возвращением, #{user.name}!"
    else
      flash.now[:alert] = "Неверная почта или пароль"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_session_path, notice: "Вы вышли из аккаунта"
  end
end
