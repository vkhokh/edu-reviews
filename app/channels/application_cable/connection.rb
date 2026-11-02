module ApplicationCable
  # WebSocket-соединение браузера с сервером (Action Cable).
  # Отзывы видны всем, поэтому пользователя не определяем.
  class Connection < ActionCable::Connection::Base
  end
end
