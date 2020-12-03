# frozen_string_literal: true

require_relative 'connection_creator'
require_relative 'user_dao'

class Dao
  attr_reader :user
  attr_reader :instance

  def initialize(config)
    @user = UserDao.new(config)
  end

  def self.get_dao(config)
    @instance || (@instance = Dao.new(config))
  end
end