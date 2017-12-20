require 'bundler'
Bundler.require(:default)

TELEGRAM_CLI_PATH = '/Users/longnh92/tg/bin/telegram-cli'
TELEGRAM_PUB = '/Users/longnh92/tg/server.pub'
TARGET_TO_CHAT_NAME = 'test'
FACTOR_NAMES = ['t', 'long']

def target_from_channel?(name)
  FACTOR_NAMES.all? do |factor|
    name.include?(factor)
  end
end

EM.run do
  telegram = Telegram::Client.new do |cfg|
    cfg.daemon = TELEGRAM_CLI_PATH
    cfg.key = TELEGRAM_PUB
    cfg.logger = Logger.new(STDOUT)
  end

  telegram.connect do
    target_group_chat = telegram.chats.find { |chat| chat.name.downcase.include?(TARGET_TO_CHAT_NAME) }

    telegram.on[Telegram::EventType::RECEIVE_MESSAGE] = Proc.new do |event|
      tgmessage = event.tgmessage
      from_name = event.message.from.name.downcase
      if target_from_channel?(from_name)
        telegram.msg('chat#' + target_group_chat.id.to_s, event.message.text)
      end
    end

    telegram.on_disconnect = Proc.new do
      puts 'Connection with telegram-cli is closed'
    end
  end
end
