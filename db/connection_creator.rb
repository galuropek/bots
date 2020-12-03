# frozen_string_literal: true

require 'mysql2'

class ConnectionCreator

  # @param [Hash] config
  def initialize(config)
    raise("Invalid MySQL config:\n#{config}") unless config_is_valid?(config)

    @connection = nil
    @config = config
  end

  def connection
    if @connection.nil? || @connection.closed?
      Mysql2::Client.new(
        host: @config['host'],
        username: @config['username'],
        password: @config['password'],
        database: @config['database']
      )
    else
      @connection
    end
  end

  # def transaction(&block)
  #   raise ArgumentError, "No block was given" unless block_given?
  #
  #   begin
  #     client.query("BEGIN")
  #     yield
  #     client.query("COMMIT")
  #   rescue StandardError
  #     client.query("ROLLBACK")
  #   end
  # end

  private

  def config_is_valid?(config)
    %w[host username password database].each do |param|
      return false if config[param].nil? || config[param].to_s.strip.empty?
    end

    true
  end
end