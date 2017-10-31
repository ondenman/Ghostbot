require 'pry'
require 'twitter'

Dir['./lib/*.rb'].each { |file| require file }

$stdout.sync = true

module TweetDecorator
  def tweet
    structure.map { |i| send(i) }.join(' ')
  end

  private

  def structure
    %i[witness witness_present_verb ghost_adjective
       ghost_noun preposition town_name location_name]
  end

  def witness
    send(:witness_noun).capitalize
  end
end

module NoWitnessDecorator
  include TweetDecorator

  private

  def structure
    %i[opening ghost_adjective ghost_noun preposition town_name location_name]
  end

  def opening
    ['Reports of', 'Sightings of'].sample
  end
end

module BreakingStoryDecorator
  include TweetDecorator

  private

  def structure
    %i(breaking ghost ghost_noun reported preposition town_name location_name)
  end

  def breaking
    'BREAKING:'
  end

  def ghost
    send(:ghost_adjective).capitalize
  end

  def reported
    %w[reported spotted].sample
  end
end

module HistoricReportDecorator
  include TweetDecorator

  private

  def structure
    %i[this_day year ghost witness_past_verb preposition town_name]
  end

  def this_day
    'On this day in'
  end

  def year
    "#{random_year}:"
  end

  def ghost
    "#{ghost_adjective.capitalize} #{ghost_noun}"
  end

  def random_year
    Time.at(from_date + rand * (to_date.to_f - from_date.to_f)).year
  end

  def from_date
    Time.local(1977, 1, 1)
  end

  def to_date
    Time.now
  end
end

class Tweeter
  def run
    rep = GhostReport.new(words: words, decorator: decorator)
    client.update(rep.full_tweet) if rep.tweet.length <= 140
    # puts rep.full_tweet
  end

  private

  def decorator
    [TweetDecorator, NoWitnessDecorator, BreakingStoryDecorator, HistoricReportDecorator].sample
  end

  def words
    @words ||= Dir['./data/*'].inject({}) do |h, file|
      h.merge(File.basename(file).to_sym => lines(file))
    end
  end

  def lines(file)
    File.readlines(file).map(&:chomp).reject(&:empty?)
  end

  def client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
  end
end

puts 'Running'

if Random.rand(5).zero?
  sleeptime = Random.rand(600)
  puts "Going to post tweet in #{sleeptime} seconds."
  sleep(sleeptime)
  tweeter = Tweeter.new
  tweeter.run
  puts 'Tweet sent'
else
  puts 'No tweet'
end
