require 'twitter'
require 'tweetstream'

class TwitterFactory
  def self.configure &config
    Twitter.configure(&config)
    TweetStream.configure(&config)
  end

  def self.twitter_client
    @twitter_client ||= Twitter::Client.new
  end

  def self.tweet_stream_client
    @tweet_stream_client ||= TweetStream::Client.new
  end
end
