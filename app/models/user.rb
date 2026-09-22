# == Пользователь ==
# Аутентификация через has_secure_password (требует гем bcrypt и колонку
# password_digest — см. миграцию db/migrate/..._create_users.rb).
#
# has_secure_password сам добавляет:
#   - виртуальные атрибуты password / password_confirmation
#   - метод authenticate(raw_password)
#   - валидацию совпадения password == password_confirmation
#     (только если password_confirmation передан, поэтому на логине это не мешает)
#   - валидацию присутствия пароля при создании записи
class User < ApplicationRecord
  has_secure_password

  before_save { self.email = email.to_s.strip.downcase }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "имеет неверный формат" }
  validates :password, length: { minimum: 6 }, allow_nil: true
end
