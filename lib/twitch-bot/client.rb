require 'twitch-bot/connection'
require 'twitch-bot/log'

module TwitchBot
    class Client
        @@IRC_ENDPOINT = 'irc.chat.twitch.tv'.freeze
        @@IRC_PORT = 6667.freeze

        def initialize(chat_token: nil, botname: nil, channel: nil)
            if chat_token.nil? && botname.nil?
                raise "A chat token and bot name are required for the bot"
            end

            if channel.nil?
                raise "We need a channel to connect to."
            end

            chat_token = "oauth:#{chat_token}"

            connection = Connection.new(
                :endpoint   => @@IRC_ENDPOINT,
                :port       => @@IRC_PORT,
                :chat_token => chat_token,
                :botname    => botname,
                :channel    => channel
            )

            connection.run

            while connection.active
                command = gets.chomp
                connection.send(command)
            end

            exit(0)
            
        end
    end
end
