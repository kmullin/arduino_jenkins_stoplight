#!/usr/bin/env ruby

%w(socket rubygems serialport yajl pp).each do |m|
  require m
end

DEBUG = false
PROJECT = 'Production'
PORT = 22222
RESPONSES = %w(1 2 3 F B)
SERIAL_PORT, SPEED = '/dev/tty.usbmodemfd121', 9600

# Jenkins notification payload for 1 test
#{"name":"testing","url":"job/testing/","build":{"full_url":"https:///jenkins/job/testing/1/","number":1,"phase":"STARTED","url":"job/testing/1/"}}
#{"name":"testing","url":"job/testing/","build":{"full_url":"https:///jenkins/job/testing/1/","number":1,"phase":"COMPLETED","status":"SUCCESS","url":"job/testing/1/"}}
#{"name":"testing","url":"job/testing/","build":{"full_url":"https:///jenkins/job/testing/1/","number":1,"phase":"FINISHED","status":"SUCCESS","url":"job/testing/1/"}}

def check_response(json_hash)
  if json_hash["name"] == PROJECT
    if json_hash["build"]["phase"] == 'FINISHED'
      case json_hash["build"]["status"]
        when 'SUCCESS'
          write_serial('3')
        when 'FAILURE'
          write_serial('1')
        when 'ABORTED'
          write_serial('F')
        else
          write_serial('2')
      end
    elsif json_hash["build"]["phase"] == 'STARTED'
      write_serial('B')
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
