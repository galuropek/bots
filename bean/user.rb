# frozen_string_literal: true

class User
  attr_accessor :id
  attr_accessor :telegram_id
  attr_accessor :username
  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :description
  attr_accessor :alias
  attr_accessor :hobbies

  def initialize(telegram_id)
    @telegram_id = telegram_id
  end
end