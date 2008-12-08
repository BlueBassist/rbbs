#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)

# Dependencies
require 'rubygems'
require 'eventmachine'
require 'term/ansicolor'
require 'logger'
require 'mash'

# Core





module RBBS
  
  class String
    include Term::ANSIColor
  end
  
  def post_init
    @server_config = YAML::load_file( '../rbbs-config.yml' )
    puts @server_config.inspect
    @next_line = "\r\n"
    @session_info = {:current_menu => 'Main'}
    @prompt = "\r\n#{@server_config['name']} - #{@session_info[:current_menu]}[h,q,m,t,d]: ".bold 
    send_data build_menu
    send_data @prompt
    @connect_time = Time.now
  end
  
  def receive_data data
    case data
    when /^(\?|h|help)/i
      option = "Your available options are:"
    when /^(q|quit)/i
      send_data "Thanks for visiting #{@server_config['name']}"
      close_connection
    when /^(m|menu)/i
      option = build_menu
    when /^(t|time)/i
      option = Time.now
    when /^(d|duration)/i
      duration = Time.now - @connect_time
      option = "You have been connected for #{duration} seconds."
    # when /^(i|identity)/i
    #   pn = get_peername
    #   option = pn ? Socket::unpack_sockaddr_in(pn) : ["?.?.?.?"]
    #   option = option.inspect
    end
    send_data "#{option}#{@prompt}"
    # send_data ">>>you sent: #{data}"
    # close_connection if data =~ /quit/i
  end
  
  def build_menu
    menu = @server_config['name']
    menu += @next_line
    20.times { menu += '-' }
    menu += @next_line
    menu += ' You are connected to TheDragon'
    menu += @next_line
    20.times { menu += '-' }
    menu
  end
end

EventMachine::run do
  EventMachine::start_server @server_config['ip'], @server_config['port'], RBBS
end