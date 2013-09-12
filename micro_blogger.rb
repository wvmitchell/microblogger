require 'jumpstart_auth'
require 'certified'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
    # Added in an instance of the bitly class in the initialize method
    @bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
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
        # Added s command to shorten url
        when 's' then shorten parts[1..-1]
        # Added turl command to tweet with url
        when 'turl' then tweet(parts[1..-2].join(' ') + " " + shorten(parts[-1]))
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
    followers_list().each { |follower| dm follower, 'SPAM FROM WILL!!!' }
  end

  def everyones_last_tweet
    friends = sort_followers(@client.friends)
    friends.each do |friend|
      # Here I created a timestamp from the friend.status object, then formated it into a nice string on the next line
      timestamp = friend.status.created_at
      puts friend.screen_name + " said on " + timestamp.strftime("%A, %b %d") 
      puts friend.status.text
      puts ""
    end
  end

  # Here we are starting iteration 4, adding the url shortening service bit.ly
  def shorten(original_url)
    # Shortening code
    @bitly.shorten(original_url).short_url
  end
end

blogger = MicroBlogger.new
blogger.run