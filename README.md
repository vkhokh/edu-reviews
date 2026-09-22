# Экраны регистрации и входа — чек-поинт 1

Готовые файлы для регистрации/входа в едином синем стиле (тот же, что выбрали
на холсте с макетами). Аутентификация — своя, на `has_secure_password` (bcrypt),
без Devise.

## Что где лежит

```
db/migrate/20260921120000_create_users.rb   — миграция для таблицы users
app/models/user.rb                          — модель User
app/controllers/sessions_controller.rb      — вход/выход
app/controllers/registrations_controller.rb — регистрация
app/controllers/application_controller_additions.rb
                                             — методы current_user/logged_in?,
                                               добавь их в свой ApplicationController
app/views/sessions/new.html.erb             — экран входа
app/views/registrations/new.html.erb        — экран регистрации
app/views/layouts/application.html.erb.example
                                             — пример layout'а (шрифты + flash),
                                               перенеси нужное в свой layout
app/assets/stylesheets/auth.css             — стили экранов (синяя палитра)
config/routes_snippet.rb                    — какие роуты добавить
```

## Шаги по установке

1. **Гем bcrypt.** В `Gemfile` обычно уже есть закомментированная строка
   `gem "bcrypt", "~> 3.1.7"` — раскомментируй её и выполни:
   ```
   bundle install
   ```

2. **Скопируй файлы** в соответствующие папки своего проекта (пути совпадают
   один в один с Rails-конвенциями).

3. **Роуты.** Добавь содержимое `config/routes_snippet.rb` в свой
   `config/routes.rb`.

4. **ApplicationController.** Добавь методы `current_user` и `logged_in?` из
   `app/controllers/application_controller_additions.rb` в свой
   `app/controllers/application_controller.rb`.

5. **Layout.** В `app/views/layouts/application.html.erb` добавь:
   - `<link>` на Google Fonts (Space Grotesk + Work Sans) в `<head>`;
   - блок вывода flash-сообщений перед `<%= yield %>`
   (полный пример — в `application.html.erb.example`).

6. **Миграция:**
   ```
   bin/rails db:migrate
   ```

7. **Проверка:**
   ```
   bin/rails server
   ```
   Открой `/registration/new` и `/session/new` (или просто `/`, если оставил
   `root to: "sessions#new"`).

## Что уже работает

- Регистрация: имя, университетская почта, пароль + подтверждение,
  валидации (уникальность почты, формат email, минимум 6 символов в пароле).
- Вход: поиск пользователя по почте + `authenticate`, ошибка одной фразой
  без уточнения, что именно неверно (почта или пароль) — так безопаснее.
- Сессия хранится в `session[:user_id]`, `current_user` доступен в любом
  контроллере/вьюхе.
- Ошибки валидации выводятся над формой.
- Поля есть с `<label>` (скрыты визуально через `.sr-only`, но остаются
  доступны для скринридеров) — вид как в макете, на одних плейсхолдерах.

## Что осознанно оставлено на потом

- «Забыли пароль?» — пока просто ссылка-заглушка (`href="#"`).
- Чекбокс согласия с правилами модерации — пока без серверной проверки,
  только `required` на фронте (когда будет страница с правилами — добавим
  валидацию и в модель).
- `root to: "sessions#new"` — временно, замени на каталог преподавателей,
  когда дойдёшь до него.
