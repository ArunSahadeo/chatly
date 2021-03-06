require 'twitch-bot/client'
require 'twitch-bot/helpers'
require 'twitch-bot/commands'

Thread.abort_on_exception = true

module TwitchBot
    class Connection
        attr_reader :active, :socket

        def initialize(params = {})
            endpoint = params.fetch(:endpoint)
            port = params.fetch(:port)
            @@chat_token = params.fetch(:chat_token)
            @@botname = params.fetch(:botname)
            @@channel = params.fetch(:channel)

            if endpoint.nil? && port.nil?
                raise "IRC endpoint and port required."
            end

            @socket = TCPSocket.new(endpoint, port)
        end

        def send_chat_message(message)
            Log.info "Sending message"
            socket.puts("PRIVMSG #{'#' + @@channel} :#{message}\r\n")
        end

        def run
            @active = true
            is_connected = false

            Log.info 'Preparing to connect...'

            socket.puts("PASS #{@@chat_token}")
            socket.puts("NICK #{@@botname}") 
            socket.puts("CAP REQ :twitch.tv/tags")
            socket.puts("CAP REQ :twitch.tv/commands")
            socket.puts("CAP REQ :twitch.tv/membership")
            socket.puts("JOIN ##{@@channel}")

            Thread.start do
                while (active) do
                    ready = IO.select([socket])

                    if ready && !is_connected
                        is_connected = true
                        puts "Connection established."
                    end

                    ready[0].each do |resp|
                        begin
                            line = resp.gets
                            match = line.match(/^:?(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
                            user_roles = line.match(/badges=([A-Za-z0-9]+)/).to_s.split("=").delete_at(0)

                            message = match && match[4]
                            message.to_s.chomp!

                            display_name = line.match(/display-name=([a-zA-Z0-9][\w]{3,24}+);/)
                            user = display_name && display_name[1]
                            user.to_s.chomp!

                            commands = Commands.new message, user_roles

                        rescue SocketError => se
                            Log.info "Got the following error with the current socket: #{se}"
                        end
                    end
                end
            end
        end

        def stop
            send_chat_message "Bye!"
            @active = false
        end
    end
end
