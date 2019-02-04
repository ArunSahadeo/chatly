module TwitchBot
    class Log
        @@logger = Logger.new(STDOUT)

        def self.info(message = '')
            unless message.to_s.strip.empty?
                @@logger.info message
            end
        end
    end
end
