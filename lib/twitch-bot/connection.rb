require 'twitch-bot/client'

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

        def send(message)
            Log.info 'Sending command'
            socket.puts message
        end

        def send_chat_message(message)
            Log.info 'Sending message'
            socket.puts("PRIVMSG #{'#' + @@channel} :#{message}\r\n")
        end

        def run
            @active = true

            Log.info 'Preparing to connect...'

            socket.puts("PASS #{@@chat_token}")
            socket.puts("NICK #{@@botname}") 
            #socket.puts("CAP REQ :twitch.tv/tags")
            #socket.puts("CAP REQ :twitch.tv/commands")
            #socket.puts("CAP REQ :twitch.tv/membership")
            socket.puts("JOIN #{'#' + @@channel}")

            Thread.start do
                while (active) do
                    ready = IO.select([socket])

                    ready[0].each do |resp|
                        line = resp.gets
                        match   = line.match(/^:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
                        message = match && match[4]
                        message.to_s.chomp!
                        user = match && match[1]
                        user.to_s.chomp!

                        case message
                        when /^!hello$/
                            send_chat_message "Hello there #{user}"
                        when /^!discord$/
                            send_chat_message "Please join our Discord community by clicking on the following link: #{ENV['DISCORD_LINK']}"
                        when /^!shutdown$/
                            stop
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
