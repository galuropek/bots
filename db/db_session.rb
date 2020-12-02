# frozen_string_literal: true

require 'mysql2'

class DBSession
  # @param [Hash] config
  def initialize(config)
    config_is_valid?(config) ? @config = config : raise("Invalid MySQL config:\n#{config}")
  end

  def query(sql_query)
    client.query(sql_query)
  end

  def transaction(&block)
    raise ArgumentError, "No block was given" unless block_given?

    begin
      client.query("BEGIN")
      yield
      client.query("COMMIT")
    rescue StandardError
      client.query("ROLLBACK")
    end
  end

  private

  def client
    @client ||= Mysql2::Client.new(
      host: @config['host'],
      username: @config['username'],
      password: @config['password'],
      database: @config['database']
    )
  end

  def config_is_valid?(config)
    %w[host username password database].each do |param|
      return false if config[param].nil? || config[param].to_s.strip.empty?
    end

    true
  end
end