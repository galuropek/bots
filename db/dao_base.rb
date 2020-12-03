# frozen_string_literal: true

require_relative 'connection_creator'

class DaoBase

  def initialize(config)
    connection_creator = ConnectionCreator.new(config)
    @connection = connection_creator.connection
  end

  def create
    not_implement
  end

  def get_all
    not_implement
  end

  def read
    not_implement
  end

  def update
    not_implement
  end

  def delete
    not_implement
  end

  def transaction(queries)
    @connection.transaction do
      queries.each do |sql|
        @connection.query(sql)
      end
    end
  end

  private

  def not_implement
    raise 'Not implement yet'
  end
end