require_relative 'crud'

class UserDao < CRUD
  def initialize(config)
    super
  end

  def get_all
    @client.query('select * from users')
  end

  # @param [Object] user
  def create(user)
    sql = 'INSERT users(telegram_id, user_name,' \
          'first_name, last_name, alias)' \
          "values('%s', '%s', '%s', '%s', '%s')" %
          [
            user.telegram_id,
            user.username,
            user.first_name,
            user.last_name,
            user.alias
          ]

    @client.query(sql)
  end
end