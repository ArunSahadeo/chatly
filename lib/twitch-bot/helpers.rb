Thread.abort_on_exception = true

module TwitchBot
    class Helpers
        def self.is_broadcaster(roles)
            roles.include?("broadcaster")
        end
        def self.is_moderator(roles)
            roles.include?("moderator")
        end
    end
end
