require_relative 'base_dao'

class UserDao < BaseDao

  # @param [Integer] limit
  def get_all(limit: 100)
    raws = @connection.query("select * from users limit #{limit}")

    raws.count.zero? ? nil : to_user(raws)
  end

  # @param [User] user
  # @return [User] || [NilClass]
  def create(user)
    return if get_user(user)

    sql = 'INSERT users(telegram_id, user_name,' \
          'first_name, last_name, alias)' \
          "VALUES('%s', '%s', '%s', '%s', '%s')" %
        [user.telegram_id, user.user_name, user.first_name, user.last_name, user.alias]

    @connection.query(sql)

    get_user(user)
  end

  # @param [User] user
  # @return [User] || [NilClass]
  def get_user(user)
    sql = "SELECT * FROM users WHERE telegram_id = '#{user.telegram_id}'"
    raws = @connection.query(sql)
    if raws.count > 1
      raise("Found more than one user by telegram_id = #{user.telegram_id}")
    else
      raws.count.zero? ? nil : to_user(raws).first
    end
  end

  # @param [User] user
  # @return [User] || [NilClass]
  def update(user)
    set = update_query_prepare(user)
    return unless set

    sql = "UPDATE users set #{set} where telegram_id = '#{user.telegram_id}'"
    @connection.query(sql)

    get_user(user)
  end

  # @param [User] user
  # @return [User] || [NilClass]
  def delete(user)
    sql = "DELETE FROM users WHERE telegram_id = '#{user.telegram_id}'"
    @connection.query(sql)

    get_user(user)
  end

  private

  # @param [User] user
  # @return [String] || [NilClass]
  def update_query_prepare(user)
    query = []
    query << "user_name = '#{user.user_name}'" if user.user_name
    query << "alias = '#{user.alias}'" if user.alias
    query << "first_name = '#{user.first_name}'" if user.first_name
    query << "last_name = '#{user.last_name}'" if user.last_name

    query.empty? ? nil : query.join(', ')
  end

  def to_user(raws)
    raws.map do |raw|
      user = User.new(raw['telegram_id'])
      user.id = raw['id']
      user.user_name = raw['user_name']
      user.first_name = raw['first_name']
      user.last_name = raw['last_name']
      user.alias = raw['alias']
      user
    end
  end
end