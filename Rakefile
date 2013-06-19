require 'rubygems'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Runs the twitter server."
task :run_server do
  require_relative 'src/twitter_factory'
  require_relative 'config/twitter_data'
  TwitterFactory.configure(&TWITTER_CONFIG)

  require 'mongo'; include Mongo
  require_relative 'config/mongo_data'

  DB = MongoClient.new MONGO_HOST, MONGO_PORT

  require_relative 'src/mongo_model'
  require_relative 'src/twitter_app'
  require_relative 'src/story_spec.rb'; STORY = LOCKEDIN
  A = App.new(TwitterFactory.twitter_client,
              TwitterFactory.tweet_stream_client,
              MongoModel.new(DB.db('test')),
              STORY)

  A.run
end
