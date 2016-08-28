module SocketExercise
  class Handler
    def initialize(@socket : TCPSocket, @logger : Logger)
      @socket.read_timeout = 0.2 # 200 ms
      @stop_flag = false
      @stop_channel = Channel(Nil).new(1)
    end

    def start
      @logger.info("Handler #{object_id} starts")
      until @stop_flag
        accept_data
      end
      close_socket
    end

    def stop!
      @stop_flag = true
    end

    def wait_stop
      unless @socket.closed?
        @stop_channel.receive
      end
    end

    private def accept_data
      data = @socket.gets
      if data
        @logger.info("Handler #{object_id} received: #{data.chomp}")
      end
    rescue IO::Timeout
      nil
    end

    private def close_socket
      @socket.close
      @logger.info("Handler #{object_id} stops")
      @stop_channel.send(nil)
    end
  end
end

