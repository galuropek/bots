# frozen_string_literal: true

require_relative 'db_session'

class CRUD
  def initialize(config)
    @client = DBSession.new(config)
  end

  def create
    not_implement
  end

  def get_all
    not_implement
  end

  def get(id)
    not_implement
  end

  def update(id)
    not_implement
  end

  def delete
    not_implement
  end

  def transaction(queries)
    @client.transaction do
      queries.each do |sql|
        @client.query(sql)
      end
    end
  end

  private

  def not_implement
    raise 'Not implement yet'
  end
end