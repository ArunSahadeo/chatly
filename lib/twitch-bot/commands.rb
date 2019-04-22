require_rel "commands"

module TwitchBot
    class Commands
        @@commands = Array.new

        def initialize(message, user_roles)
            @user_roles = user_roles
            self.registerCommand("purge", Purge, ["moderator", "broadcaster"])

            case message
            when /^!purge/
                command = @@commands.select { |command| command['name'] == 'purge' }
                command = command[0]
                command_args = message.split(' ')
                username = command_args[1]

                unless command.length < 1 || username.nil?
                    command = Object::const_get(command['handler'].to_s)
                    command.new username
                end
            end
        end

        def registerCommand(name, handler, allowed_roles)
            command = {
                "name"            => name,
                "handler"         => handler,
                "allowed_roles"   => allowed_roles
            }
            
            commandExists = @@commands.any? { |comm| comm['name'] == command['name'] }

            unless commandExists
                @@commands.push(command)
            end
        end
    end
end
