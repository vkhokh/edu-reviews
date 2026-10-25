ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Параллельный запуск отключён: Rails включает его, когда тестов больше 50,
    # а SQLite при записи из нескольких потоков падает ("database is locked",
    # "cannot start a transaction within a transaction").
    # parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Помощники для интеграционных тестов (сквозные сценарии через HTTP).
class ActionDispatch::IntegrationTest
  PASSWORD = "secret123".freeze # такой пароль у пользователей из фикстур

  # Входит под пользователем так же, как это делает форма входа.
  def log_in_as(user, password: PASSWORD)
    post session_path, params: { session: { email: user.email, password: password } }
  end
end
