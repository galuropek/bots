require_relative 'dao_base'

class UserDao < DaoBase

  def get_all(limit: 100)
    @connection.query("select * from users limit #{limit}")
  end

  def create(user)
    sql = 'INSERT users(telegram_id, user_name,' \
          'first_name, last_name, alias)' \
          "VALUES('%s', '%s', '%s', '%s', '%s')" %
          [user.telegram_id, user.username, user.first_name, user.last_name, user.alias]

    @connection.query(sql)
  end

  def read(user)
    sql = "SELECT * FROM users WHERE telegram_id = '#{user.telegram_id}'"
    raws = @connection.query(sql)

    raws.count.zero? ? nil : raws
  end

  def update(user)
    set = update_query_prepare(user)
    return unless set

    sql = "UPDATE users set #{set} where telegram_id = '#{user.telegram_id}'"
    @connection.query(sql)

    read(user)
  end

  def delete(user)

  end

  private

  def update_query_prepare(user)
    query = []
    query << "user_name = '#{user.user_name}'" if user.user_name
    query << "alias = '#{user.alias}'" if user.alias
    query << "first_name = '#{user.first_name}'" if user.first_name
    query << "last_name = '#{user.last_name}'" if user.last_name
    query.empty? ? nil : query.join(', ')
  end
end