# frozen_string_literal: true

# require_relative 'secret_santa'
#
# SecretSanta.new.run

# require 'mysql2'
# require 'yaml'
#
# config = YAML.load_file('config.yml')['mysql']
# client = Mysql2::Client.new(
#     :host => config['host'],
#     :username => config['username'],
#     :password => config['password'],
#     :database => config['database']
# )
#
# results = client.query("select * from users u join user_details ud on ud.user_id = u.id where u.id = 1")
# results.each do |row|
#   puts row.inspect
# end
#
require 'yaml'
require_relative '../db/user_dao'
require_relative '../bean/user'
require_relative '../db/dao'

config = YAML.load_file('config.yml')['telegram_bot']
dao = Dao.get_dao(config)
user = User.new('1293764')
user.alias = 'Игорь'
user.hobbies = 'hobbies'
# puts user.user_details?
# puts dao.user.delete(user).inspect
