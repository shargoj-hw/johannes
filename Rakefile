require 'rubygems'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Runs the twitter server."
task :run_server do
  require_relative 'src/twitter_factory'
  require_relative 'config/twitter_data'
  TwitterFactory.configure(&TWITTER_CONFIG)

  require 'mongo'
  require 'uri'

  def get_connection
    return @db_connection if @db_connection
    db = URI.parse(ENV['MONGOHQ_URL'])
    db_name = db.path.gsub(/^\//, '')
    @db_connection = Mongo::MongoClient.new(db.host, db.port).db(db_name)
    @db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
    @db_connection
  end

  DB = get_connection

  require_relative 'src/mongo_model'
  require_relative 'src/twitter_app'
  require_relative 'src/story_spec.rb'; STORY = LOCKEDIN
  A = App.new(TwitterFactory.twitter_client,
              TwitterFactory.tweet_stream_client,
              MongoModel.new(DB),
              STORY)

  A.run
end
