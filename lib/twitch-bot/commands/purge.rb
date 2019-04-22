require 'twitch-bot/helpers'

class Purge
    include TwitchBot

    def initialize (username)
        self.run(username)
    end 

    def run (username)
        Connection.send_chat_message "WOO NOO" 
    end
end
