require "logger"
require "option_parser"

require "./socket_exercise/*"

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::DEBUG

mode = :server
port = 8080_u16

OptionParser.parse! do |parser|
  parser.banner = "Usage: socket_exercise [arguments]"
  parser.on("-s", "--server", "Start the server") { mode = :server }
  parser.on("-c", "--client", "Start the client") { mode = :client }
  parser.on("-p PORT", "--port=PORT", "Specifies the port to use") { |p| port = p.to_u16 }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

if mode == :server
  server = SocketExercise::Server.new(8080_u16, LOGGER)
  spawn { server.start }
  Signal::INT.trap { server.stop! ; exit 0 }
else
  # TODO: implement the client
  #
  # Use telnet to play with this for now...

  puts "Client is not yet implemented"
end

sleep
