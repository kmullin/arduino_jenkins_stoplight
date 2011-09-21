#!/usr/bin/env ruby

%w(socket rubygems serialport yajl pp).each do |m|
  require m
end

DEBUG = true
PROJECT = 'testing'
PORT = 22222
RESPONSES = %w(1 2 3 F B)
SERIAL_PORT, SPEED = '/dev/tty.usbmodemfd121', 9600

def check_response(json_hash)
  if json_hash["name"] == PROJECT
    if json_hash["build"]["phase"] == 'FINISHED'
      if json_hash["build"]["status"] == 'SUCCESS'
        write_serial('3')
      elsif json_hash["build"]["status"] == 'FAILURE'
        write_serial('1')
      elsif json_hash["build"]["status"] == 'ABORTED'
        write_serial('F')
      else
        write_serial('2')
      end
    end
  end
end

def write_serial(data)
  if RESPONSES.include?(data)
    puts "Serial Sending '#{data}'" if DEBUG
    @serial.write(data)
  end
end

begin
  @serial = SerialPort.new(SERIAL_PORT,SPEED)
rescue Errno::ENOENT
  puts "Can't find #{SERIAL_PORT}"
  exit(1)
end
@server = TCPServer.open(PORT.to_i)

count = 0
loop {
  client = @server.accept
  count += 1
  puts "Client \##{count}" if DEBUG
  begin
    hash = Yajl::Parser.parse(client.read(512))
    client.close
    check_response(hash)
  rescue Yajl::ParseError
    puts "Client \##{count} - Error parsing" if DEBUG
    next
  end
}
