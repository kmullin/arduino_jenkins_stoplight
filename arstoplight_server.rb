#!/usr/bin/env ruby

begin
  require 'serialport'
rescue LoadError
  require 'rubygems'
  require 'serialport'
end

%w(socket yajl pp net/https).each do |m|
  require m
end

DEBUG = true # print debug information
PROJECT = 'Production' # name of project to build
PORT = 22222 # port to listen on for notifications from Jenkins
RESPONSES = %w(1 2 3 F B) # these are the ASCII characters that are valid on the arduino
SERIAL_PORT, SPEED = '/dev/tty.usbmodemfa141', 9600

JENKINS_URL = ""
USERNAME, PASSWORD = '',''
# Jenkins notification payload for 1 test
#{"name":"testing","url":"job/testing/","build":{"full_url":"https:///jenkins/job/testing/1/","number":1,"phase":"STARTED","url":"job/testing/1/"}}
#{"name":"testing","url":"job/testing/","build":{"full_url":"https:///jenkins/job/testing/1/","number":1,"phase":"COMPLETED","status":"SUCCESS","url":"job/testing/1/"}}
#{"name":"testing","url":"job/testing/","build":{"full_url":"https:///jenkins/job/testing/1/","number":1,"phase":"FINISHED","status":"SUCCESS","url":"job/testing/1/"}}

def check_response(json_hash)
  pp json_hash if DEBUG
  if json_hash["name"] == PROJECT
    if json_hash["build"]["phase"] == 'FINISHED'
      case json_hash["build"]["status"]
        when 'SUCCESS'
          write_serial('3')
        when 'FAILURE'
          write_serial('1')
        when 'ABORTED'
          write_serial('B')
        else
          write_serial('2')
      end
    elsif json_hash["build"]["phase"] == 'STARTED'
      write_serial('F')
    end
  end
end

def write_serial(data)
  if RESPONSES.include?(data)
    puts "Serial Sending '#{data}'" if DEBUG
    @serial.write(data)
  end
end

def request_build
  url = URI.parse(JENKINS_URL)
  http = Net::HTTP.new(url.host, 443)
  http.use_ssl = true
  http.start do |http|
    req = Net::HTTP::Get.new(url.path)
    req.basic_auth USERNAME, PASSWORD
    http.request(req)
  end
  puts "requesting build #{JENKINS_URL}"
end

begin
  @serial = SerialPort.new(SERIAL_PORT,SPEED)
  @serial.read_timeout = 500
rescue Errno::ENOENT
  puts "Can't find #{SERIAL_PORT}"
  exit(1)
end
@server = TCPServer.open(PORT.to_i)

count = 0
loop {
  begin
    client = @server.accept_nonblock
  rescue
    request_build if @serial.read =~ /BUILD/
    retry
  end
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
