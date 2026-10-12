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
