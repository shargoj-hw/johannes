require 'twitter'
require 'tweetstream'
require 'mongo'; include Mongo

require_relative './command_parser'

require_relative './twitter_data'
require_relative './mongo_data'

Twitter.configure(&TWITTER_CONFIG)
TweetStream.configure(&TWITTER_CONFIG)

DB = MongoClient.new MONGO_HOST, MONGO_PORT

class App
  def initialize client, stream_client, database, story_data
    @client = client
    @stream_client = stream_client
    @db = database
    @story_data = story_data

    _setup_twitter!
  end

  def run
    @stream_client.userstream
  end

  def stories
    @db['stories_in_progress']
  end

  private
  def _setup_twitter!
    @stream_client.on('follow', &method(:_on_follow))
    @stream_client.on_direct_message(&method(:_on_direct_message))
  end

  def _on_follow data
    other_user = data[:source][:id]

    @client.follow other_user
    @client.direct_message_create other_user, "Let's get to work."
  end

  def _on_direct_message direct_message
    sender_id = direct_message[:sender][:id]
    return if @client.user.id == sender_id

    puts 'getting story'
    gamestate = _in_progress_story sender_id

    puts text = direct_message[:text]

    new_gamestate = run_command(text,
                                gamestate,
                                @story_data.commands)

    _in_progress_story! sender_id, new_gamestate

    puts new_gamestate.inspect

    @client.direct_message_create sender_id, "ran #{text}"
  end

  def _in_progress_story twitter_id
    in_progress = stories.find_one('twitter_id' => twitter_id)
    if in_progress.nil?
      story = @story_data.initial_gamestate
      stories.insert(_make_in_progress_story(twitter_id, story))

      story
    else
      GameState.from_mongo @story_data.initial_gamestate, in_progress['story']
    end

  end

  def _in_progress_story! twitter_id, gamestate
    stories.update(_make_in_progress_story(twitter_id, gamestate))
  end

  def _make_in_progress_story twitter_id, gamestate
    {'twitter_id'=>twitter_id, 'story'=>gamestate.to_mongo}
  end
end

require_relative './story_spec.rb'

A = App.new(Twitter::Client.new,
            TweetStream::Client.new,
            DB.db('test'),
            LOCKEDIN)

# A.run
