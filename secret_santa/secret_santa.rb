# frozen_string_literal: true

require 'telegram/bot'
require 'yaml'

class SecretSanta
  def run
    run_telegram_bot
  end

  private

  def run_telegram_bot
    Telegram::Bot::Client.run(token) do |bot|
      bot.listen do |message|
        case message
        when Telegram::Bot::Types::CallbackQuery
          handle_callback(bot, message)
        when Telegram::Bot::Types::Message
          handle_message(bot, message)
        end
      end
    end
  end

  def handle_message(bot, message)
    case message.text
    when '/start'
      kb = [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Показать санту', callback_data: 'show_my_santa'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Кто уже проверял санту', callback_data: 'who_checked')
      ]
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      bot.api.send_message(chat_id: message.chat.id, text: 'Что показать?', reply_markup: markup)
    when '/help'
      bot.api.send_message(chat_id: message.chat.id, text: "Доступные команды:\n/start - запустить главное меню бота\n/help - список команд")
    else
      bot.api.send_message(chat_id: message.chat.id, text: "#{message.from.first_name}, ты себя плохо вел(а) в этом году... или такой команды нет!) Попробуй /help :)")
    end
  end

  def handle_callback(bot, message)
    # Here you can handle your callbacks from inline buttons
    case message.data
    when 'show_my_santa'
      bot.api.send_message(chat_id: message.from.id, text: "Твой санта это...")
    when 'who_checked'
      bot.api.send_message(chat_id: message.from.id, text: "Санту уже проверили")
    end
  end

  def token
    @token ||= YAML.load_file(Dir.pwd + '/secret_santa/config.yml')['token']
  end
end