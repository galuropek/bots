# frozen_string_literal: true

class User
  attr_accessor :id
  attr_accessor :telegram_id
  attr_accessor :user_name
  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :description
  attr_accessor :alias
  attr_accessor :hobbies

  def initialize(telegram_id)
    @telegram_id = telegram_id
  end

  def to_s
    "id: #{id} " \
"| telegram_id: #{telegram_id.inspect} " \
"| user_name: #{user_name.inspect} " \
"| first_name: #{first_name.inspect} " \
"| last_name: #{last_name.inspect} " \
"| description: #{description.inspect} " \
"| alias: #{self.alias.inspect} " \
"| hobbies: #{hobbies.inspect}"
  end
end