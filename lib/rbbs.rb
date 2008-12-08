#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)

# Dependencies
require 'rubygems'
require 'eventmachine'
require 'term/ansicolor'
require 'logger'
require 'mash'

# Core



  
class String
  include Term::ANSIColor
end

module RBBS
    
  
  def post_init
    @server_config = Mash.new(YAML::load_file( '../config/rbbs-config.yml' ))
    @next_line = "\r\n"
    @session_info = {:current_menu => 'Main'}
    @prompt = "\r\n#{@server_config.name} - #{@session_info[:current_menu]}[h,q,m,t,d]: ".bold 
    send_data build_menu('main')
    send_data @prompt
    @connect_time = Time.now
  end

      
  def receive_data data
    case data
    when /^(\?|h|help)/i
      option = "Your available options are:"
    when /^(q|quit)/i
      send_data "Thanks for visiting #{@server_config.name}"
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
  
  # def build_menu(section)
  #   menu_items = YAML::load_file("../config/#{section}-menu.yaml").to_a
  #   menu = @server_config.name
  #   menu_line
  #   # puts menu_items.inspect
  #   menu_items.each do |row|
  #     puts row.last[1].inspect
  #     row = row.last.to_a
  #     puts row.inspect
  #     # line = Mash.new({:a => item.[1], :b => item.[3]})
  #     # puts line.inspect
  #     # menu_line(line)
  #   end
  #   menu_line
  # end
  
  def menu_line(text_col = {})
    line = ''
    if text_col.empty?
      @server_config.screenwidth.times do
        line += '-'
      end
    else
      whitespace = (@server_config.screenwidth - text_col.a.length - text_col.b.length)/3
      line += '|'
      whitespace.times do
        line += ' '
      end
      line += text_col.a
      whitespace.times do
        line += ' '
      end
      line += text_col.b
      whitespace.times do
        line += ' '
      end
      line += '|'
    end
    return line
  end
end
EventMachine::run do
  EventMachine::start_server '0.0.0.0', 8080, RBBS
end