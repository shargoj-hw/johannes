require_relative './command_parser'

class App
  def initialize client, stream_client, model, story
    @client = client
    @stream_client = stream_client
    @model = model
    @story = story

    setup_twitter!
  end

  def run
    @stream_client.userstream
  end

  private
  def setup_twitter!
    @stream_client.on('follow', &method(:on_follow))
    @stream_client.on_direct_message(&method(:debug_on_direct_message))
  end

  def on_follow data
    other_user = data[:source][:id]

    @client.follow other_user
    @client.direct_message_create other_user, "Let's get to work."
  end

  def on_direct_message direct_message
    twitter_id = direct_message[:sender][:id]
    return if @client.user.id == twitter_id

    story = @model.get_story twitter_id
    text = direct_message[:text]

    new_gamestate, message = run_command(text, story)

    @model.update_story! twitter_id, new_gamestate

    @client.direct_message_create twitter_id, message
  end

  def debug_on_direct_message direct_message
    begin
      twitter_id = direct_message[:sender][:id]
      return if @client.user.id == twitter_id

      puts 'getting story'
      story = @model.get_story @story, twitter_id

      puts text = direct_message[:text]

      new_gamestate, message = run_command(text, story)

      puts new_gamestate.inspect
      puts message

      @model.update_story! twitter_id, new_gamestate

      puts 'wrote story'
      @client.direct_message_create twitter_id, message
      puts 'sent message'
    rescue Exception => e
      puts e.inspect
      puts e.backtrace
    end
  end
end

require 'twitter'
require 'tweetstream'
require 'mongo'; include Mongo

require_relative './twitter_data'
require_relative './mongo_data'

require_relative './mongo_model'

Twitter.configure(&TWITTER_CONFIG)
TweetStream.configure(&TWITTER_CONFIG)

DB = MongoClient.new MONGO_HOST, MONGO_PORT

require_relative './story_spec.rb'

A = App.new(Twitter::Client.new,
            TweetStream::Client.new,
            MongoModel.new(DB.db('test')),
            LOCKEDIN)

A.run
