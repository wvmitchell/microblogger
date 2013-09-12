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
end

blogger = MicroBlogger.new
blogger.tweet("MicroBlogger Initialized Initialized")