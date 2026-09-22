# Это НЕ отдельный файл для копирования как есть — добавь эти методы
# в свой существующий app/controllers/application_controller.rb.
#
# Пример итогового файла:
#
# class ApplicationController < ActionController::Base
#   helper_method :current_user, :logged_in?
#
#   private
#
#   def current_user
#     @current_user ||= User.find_by(id: session[:user_id])
#   end
#
#   def logged_in?
#     current_user.present?
#   end
#
#   # Пригодится позже, когда появятся закрытые страницы (например, форма отзыва):
#   def require_login
#     return if logged_in?
#
#     redirect_to new_session_path, alert: "Сначала войдите в аккаунт"
#   end
# end
