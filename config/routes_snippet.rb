# Добавь это в свой config/routes.rb (внутрь Rails.application.routes.draw do ... end).
# Если корень (root) уже занят под что-то другое — просто не добавляй строку с root.

resource :registration, only: %i[new create]
resource :session,      only: %i[new create destroy]

root to: "sessions#new" # временно, пока нет каталога преподавателей
