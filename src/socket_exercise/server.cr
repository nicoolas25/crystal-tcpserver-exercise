require "http/server"

module SocketExercise
  class Server
    def initialize(@port : UInt16, @logger : Logger)
      @server = TCPServer.new(@port)
      @server.read_timeout = 0.5 # 500 ms
      @stop_flag = false
      @stop_channel = Channel(Nil).new(1)
      @connection_handers = [] of Handler
    end

    def start
      @logger.info("Listening on http://0.0.0.0:#{@port}")
      until @stop_flag
        accept_connection
      end
      close_server
    end

    def stop!
      @stop_flag = true
      @stop_channel.receive
    end

    private def handle_socket(socket : TCPSocket)
      handler = Handler.new(socket, @logger)
      @connection_handers << handler
      spawn { handler.start }
    end

    private def close_server
      close_handlers
      @server.close
      @logger.info("The server is now closed")
      @stop_channel.send(nil)
    end

    private def close_handlers
      @connection_handers.each { |handler| handler.stop! }
      @connection_handers.each { |handler| handler.wait_stop }
      @connection_handers = [] of Handler
    end

    private def accept_connection
      socket = @server.accept
      handle_socket(socket)
    rescue IO::Timeout
      nil
    end
  end
end
