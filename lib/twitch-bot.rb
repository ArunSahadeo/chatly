require "twitch-bot/version"
require "twitch-bot/client"

module TwitchBot
    def self.new *args
        Client.new(*args)
    end
end
