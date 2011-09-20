#!/usr/bin/env ruby

%w(socket rubygems serialport).each do |m|
  require m
end

PORT = 22222
RESPONSES = ['1', '2', '3', 'F']

def check_responses(data)
  if RESPONSES.include?(data)
    return data
  end
end

server = TCPServer.open(PORT.to_i)
loop {
  client = server.accept
  stuff = check_responses(client.read(1))
  client.puts stuff unless stuff.nil?
  client.close
}
