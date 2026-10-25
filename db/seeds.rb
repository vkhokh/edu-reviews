# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

[
  { name: "Абрамян А. В.", department: "Мехмат" },
  { name: "Козак А. В.", department: "Мехмат" },
  { name: "Михалкович С. С.", department: "Мехмат" },
  { name: "Ячменёва Н. А.", department: "Мехмат" }
].each do |attrs|
  Teacher.find_or_create_by!(name: attrs[:name]) { |t| t.department = attrs[:department] }
end

[
  { title: "Непрерывная математика", teacher: "Абрамян А. В.",
    description: "Основы непрерывной математики: пределы, ряды, элементы анализа. Лекции и практика." },
  { title: "Матанализ", teacher: "Козак А. В.",
    description: "Классический курс математического анализа: функции, производные, интегралы." },
  { title: "Языки программирования", teacher: "Михалкович С. С.",
    description: "Устройство и сравнение языков программирования, парадигмы, практические задания." },
  { title: "Теория алгоритмов", teacher: "Ячменёва Н. А.",
    description: "Алгоритмы и их сложность, вычислимость, основные структуры данных." }
].each do |attrs|
  teacher = Teacher.find_by!(name: attrs[:teacher])
  Course.find_or_create_by!(title: attrs[:title]) do |c|
    c.teacher = teacher
    c.description = attrs[:description]
  end
end
