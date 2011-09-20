#!/usr/bin/env ruby

%w(socket rubygems serialport yajl pp).each do |m|
  require m
end

test_json = '{
  "name":"JobName",
  "url":"JobUrl",
  "build":{
    "number":1,
    "phase":"STARTED",
    "status":"FAILED",
    "url":"job/project/5",
    "fullUrl":"http://ci.jenkins.org/job/project/5"
  }
}'

PORT = 22222
RESPONSES = ['1', '2', '3', 'F']
SERIAL_PORT, SPEED = '/dev/tty.usbmodemfd121', 9600

def check_responses(data)
  if RESPONSES.include?(data)
    write_serial data
    return data
  end
end

def write_serial(data)
  @serial.write(data)
end

@serial = SerialPort.new(SERIAL_PORT,SPEED)
@server = TCPServer.open(PORT.to_i)
loop {
  client = @server.accept
  stuff = check_responses(client.read(1))
  client.puts stuff unless stuff.nil?
  client.close
}
