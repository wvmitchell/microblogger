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
        when 'dm' then dm parts[1], parts[2..-1].join(' ')
        when 'sp' then spam_my_followers
        when 'et' then everyones_last_tweet
        else puts "Sorry I don't know how to (#{command})!"
      end
    end
  end

  def dm(target, message)
    valid_target(target) ? tweet("d #{target} #{message}") : (puts "Sorry, but #{target} is not one of your followers")
  end

  def valid_target(target)
    followers_list().include?(target) ? true : false
  end

  def followers_list
    @client.followers.collect { |follower| follower.screen_name}
  end

  def sort_followers(friends)
    friends.sort_by {|friend|friend.screen_name.downcase}     
  end

  def spam_my_followers
    followers_list().each do |follower|
      dm follower, 'SPAM FROM WILL!!!'
    end
  end

  def everyones_last_tweet
    friends = sort_followers(@client.friends)
    friends.each do |friend|
      # find each friends's last message
      puts friend.screen_name + " said..."
      puts friend.status.text
      # print each friends's screen name
      # print each friends's message
      puts ""
    end
  end
end

blogger = MicroBlogger.new
blogger.run