require 'jumpstart_auth'
require 'certified'
require 'bitly'
require 'klout'

class MicroBlogger
  attr_reader :client, :bitly

  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
    # Added in an instance of the bitly class in the initialize method
    @bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    # Add in klout api key
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def tweet(message)
    message.length <= 140 ? @client.update(message) : (puts "Sorry, that message is too long!")
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != 'q'
      printf "enter command ('l' for list of commands): "
      parts = gets.chomp.split(' ')
      command = parts[0]
      case command
        when 'q' then puts 'Goodbye!'
        when 'l' then command_list
        when 't' then tweet parts[1..-1].join(' ')
        when 'dm' then dm parts[1], parts[2..-1].join(' ')
        when 'sp' then spam_my_followers parts[1..-1].join(' ')
        when 'et' then everyones_last_tweet
        # Added s command to shorten url
        when 's' then shorten parts[1..-1]
        # Added turl command to tweet with url
        when 'turl' then tweet(parts[1..-2].join(' ') + " " + shorten(parts[-1]))
        # Added klout command to find klout of friends
        when 'klout' then klout_score
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
    @client.followers.collect {|follower| follower.screen_name}
  end

  def sort_followers(followers)
    followers.sort_by {|follower| follower.screen_name.downcase}     
  end

  def spam_my_followers(message)
    followers_list().each { |follower| dm follower, message }
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

  def klout_score
    friends = @client.friends.collect {|f| f.screen_name}
    friends.each do |friend|
      identity = Klout::Identity.find_by_screen_name(friend)
      user = Klout::User.new(identity.id)
      klout = user.score.score
      puts "#{friend} has a klout of..."
      puts klout
      puts "" 
    end
  end

  def command_list
    puts "    t <tweet message>                   : Send a new Tweet"
    puts "    dm <username> <direct message>      : Send a <direct message> to <username>"
    puts "    sp <message>                        : Spam all your followers with <message>"
    puts "    et                                  : Print all of your friends most recent Tweets"
    puts "    s <url>                             : Shorten the given <url>"
    puts "    turl <tweet message> <url>          : Send a new tweet message with a shortened url"
    puts "    klout                               : See the klout score of all your friends"
    puts "    q                                   : quit"
  end
end

blogger = MicroBlogger.new
blogger.run