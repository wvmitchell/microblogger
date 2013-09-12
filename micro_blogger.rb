require 'jumpstart_auth'
require 'certified'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    message.length <= 140 ? @client.update(message) : (puts "Sorry, that message is too long!")
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != 'q'
      printf "enter command: "
      parts = gets.chomp.split(' ')
      command = parts[0]
      case command
        when 'q' then puts 'Goodbye!'
        when 't' then tweet parts[1..-1].join(' ')
        else puts "Sorry I don't know how to (#{command})!"
      end
    end
  end
end

blogger = MicroBlogger.new
blogger.run