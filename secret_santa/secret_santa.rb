# frozen_string_literal: true

require_relative '../bean/user'

require '../db/dao'
require 'telegram/bot'
require 'yaml'

class SecretSanta
  CONFIG = 'config.yml'.freeze
  GENERATED_RESULT = 'generated_result.yml'.freeze
  USERS_FILE = 'users.yml'.freeze
  HOBBIES_REGEXP = /^\s*\"*\s*ХОББИ\s*\"*\s*:/i
  ALL_USERS_EXPECTED_COUNT = 6
  ADMIN_ID = '584548282'.freeze

  def run
    @dao = Dao.get_dao(YAML.load_file('config.yml')['telegram_bot'])
    run_telegram_bot
  end

  private

  def run_telegram_bot
    Telegram::Bot::Client.run(token, logger: Logger.new($stdout)) do |bot|
      bot.logger.info('Bot has been started')
      bot.listen do |message|
        case message
        when Telegram::Bot::Types::CallbackQuery
          handle_callback(bot, message)
        when Telegram::Bot::Types::Message
          handle_message(bot, message)
        else
          raise 'Something went wrong'
        end
      end
    end
  end

  def handle_callback(bot, message)
    # Here you can handle your callbacks from inline buttons
    case message.data
    when 'show_my_santa'
      begin
        user_id = YAML.load_file(GENERATED_RESULT)[message.from.id]
        return bot.logger.error("Not found user #{message.from.id} in Generated file, check file.") unless user_id

        user = YAML.load_file(USERS_FILE)[user_id]
        user_name = user[:alias] ? user[:alias] : user[:fisrt_name]
        text = "Вы тайный санта для: #{user_name}\nХобби информация:\n#{user[:hobbies]}"
      rescue Errno::ENOENT
        count = YAML.load_file(USERS_FILE).count
        text = "Не все участники еще зарегистрированы для генерации случайного санты: #{count}/#{ALL_USERS_EXPECTED_COUNT}"
        bot.logger.error("Not found #{GENERATED_RESULT} file. Sent to user: #{text}")
      end
    when 'show_my_hobbies'
      text = get_hobbies(message.from.id) || 'text'
    else
      raise 'Something went wrong'
    end

    bot.api.send_message(chat_id: message.from.id, text: text)
  end

  def get_hobbies(id)
    user = @dao.user.read_by(telegram_id: id)
    user.hobbies
  end

  def handle_message(bot, message)
    case message.text
    when '/start'
      start_functionality(bot, message)
    when '/help'
      bot.api.send_message(chat_id: message.chat.id, text: "Доступные команды:\n/start - запустить главное меню бота\n/help - список команд\nХOББИ: - чтобы добавить или обновить Хобби информацию, нужно ввести в чате \"ХOББИ:\" и дальше саму информацию о хобби, пример:\n\nХОББИ: люблю творчество Ольги Бузовой, котов Сфинксов, рисовать, нравятся кроксы...")
    when '/generate'
      if message.from.username == 'galuropek'
        if File.exist?(GENERATED_RESULT)
          text = "File #{GENERATED_RESULT} exists. Remove for creating a new file."
        else
          result = {}
          result = santa_generate(bot) while result_valid?(result) == false
          File.open(GENERATED_RESULT, 'w') { |file| file.write(result.to_yaml) }
          text = "Generated result is valid: #{result_valid?(result)}"
          # send_msg_to_all(bot)
        end
        bot.api.send_message(chat_id: message.chat.id, text: text)
      else
        bot.api.send_message(chat_id: message.chat.id, text: "#{message.from.first_name}, ты себя плохо вел(а) в этом году... или такой команды нет!) Попробуй /help :)")
      end
    when HOBBIES_REGEXP
      if hobbies_valid?(bot, message)
        update_hobbies_info(bot, message)
        start_functionality(bot, message)
      end
    when %r{/.*}
      bot.api.send_message(chat_id: message.chat.id, text: "#{message.from.first_name}, ты себя плохо вел(а) в этом году... или такой команды нет!) Попробуй /help :)")
    else
      bot.api.send_message(chat_id: message.chat.id, text: "#{message.from.first_name}, ты себя плохо вел(а) в этом году... или такой команды нет!) Попробуй /help :)")
    end
  end

  def start_functionality(bot, message)
    user_name = message.from.first_name ? message.from.first_name : message.from.username || 'Secret Santa'
    user = @dao.user.read_by(telegram_id: message.from.id)

    if user_valid?(user)
      kb = [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Узнайте чей вы санта', callback_data: 'show_my_santa'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Ваша Хобби информация', callback_data: 'show_my_hobbies')
      ]
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      bot.api.send_message(chat_id: message.chat.id, text: "Хо-хо-хо, #{user_name}! Теперь можно узнать чей вы санта.", reply_markup: markup)
    else
      create_a_new_user(bot, message) unless user
      bot.api.send_message(chat_id: message.chat.id, text: "Добро пожаловать в чат-бот Secret Santa, #{user_name}!\nНачнем с того, что поможем своему санте выбрать подходящий подарок для вас. Расскажите немного о себе, о своих хобби: фильмы, игры, спорт, вышивание - все это может быть полезным при выборе подарка.\n(обязательно к заполнению для дальнейшего функционала)\n\nЧтобы добавить или обновить Хобби информацию, нужно ввести в чате \"ХOББИ:\" и дальше саму информацию о хобби, пример:\nХОББИ: мои хобби...", callback_data: 'add_hobies')
    end
  end

  def user_valid?(user)
    return unless user

    hobbies = user.hobbies
    hobbies.nil? || hobbies.strip.empty? ? false : true
  end

  def create_a_new_user(bot, message)
    user = User.new(message.from.id)
    user.user_name = message.from.username
    user.first_name = message.from.first_name
    created_user = @dao.user.create(user)

    if created_user
      msg_text = "Created a new user => #{created_user.to_s}"
      bot.logger.info(msg_text)
    else
      msg_text = "User not created => #{user.to_s}"
      bot.logger.error(msg_text)
    end

    bot.api.send_message(chat_id: ADMIN_ID, text: msg_text)
  end

  def hobbies_valid?(bot, message)
    hobbies_line = message.text.gsub(HOBBIES_REGEXP, '').strip
    bot.api.send_message(chat_id: message.chat.id, text: 'После команды "ХОББИ:" пусто, нужно ввести саму информацию о хобби после команды, попробуйте еще раз, см. /help') if hobbies_line.empty?
    !hobbies_line.empty?
  end

  def update_hobbies_info(bot, message)
    user = @dao.user.read_by(telegram_id: message.from.id)

    unless user
      bot.logger.error("Not found user: #{user.to_s}")
      return
    end

    history_hobbies = user.hobbies
    user.hobbies = message.text.gsub(HOBBIES_REGEXP, '').strip
    updated_user = @dao.user.update(user)

    if updated_user
      msg_text = "Ваша хобби информация обновлена\nбыло:\n#{history_hobbies}\nстало:\n#{user.hobbies}"
      bot.logger.info("Updated hobbies by #{user.alias.empty? ? user.alias : user.first_name}: #{history_hobbies} => #{user.hobbies}")
    else
      msg_text = 'Что-то пошло не так, попробуйте еще раз или см. /help'
      bot.logger.error("Hobbies not updated => #{user.to_s}")
    end

    bot.api.send_message(chat_id: message.chat.id, text: msg_text)
  end

  def send_msg_to_all(bot)
    users_keys.each do |user_id|
      bot.api.send_message(chat_id: user_id, text: 'Генерация готова, теперь можно узнать кто ваш тайный санта.')
    end
  end

  def santa_generate(bot)
    result = {}
    selected = []
    users_keys.each do |person|
      dup_names = users_keys.dup
      dup_names.delete(person)
      selected.each do |selected_name|
        dup_names.delete(selected_name)
      end
      result[person] = dup_names.sample
      selected << result[person]
    end
    bot.logger.info(result)
    result
  end

  def result_valid?(result)
    return false unless result

    if result.empty?
      false
    elsif result.keys.count != result.keys.uniq.count
      false
    elsif result.values.count != result.values.uniq.count
      false
    else
      result.values.count == result.values.compact.count
    end
  end

  def token
    @token ||= YAML.load_file(CONFIG).dig('sdiyhgf_bot', 'token')
  end
end