# encoding: utf-8
#


if User.count == 0
  puts "Creating default Admin User (admin@example.com)"
  require 'io/console'

  password = STDIN.getpass("Password (min 6 char): ")
  User.create!(email: 'admin@example.com', password: password, skip_password_validation: true, role: 'admin')

  Setting.read_yaml
  load "db/seeds/#{Setting.key}.rb"
end
