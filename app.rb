require 'pry'
require 'twitter'

Dir['./lib/*.rb'].each { |file| require file }

$stdout.sync = true

module TweetStrategy

  def full_tweet
    [
      "#{tweet}. #{hash_tags}",
      "#{tweet}. #{additional_note} #{hash_tags}"
    ].sample
  end

  private

  def tweet
    structure.map { |i| send(i) }.join(' ')
  end

  def structure
    %i[witness witness_present_verb ghost_adjective
       ghost_noun preposition town_name location_name]
  end

  def witness
    send(:witness_noun).capitalize
  end

  def hash_tags
    "\##{town_hashtag} \##{town_hashtag}#{location_hashtag}"
  end

  def town_hashtag
    town_name.gsub(/[^0-9a-z]/i, '')
  end

  def location_hashtag
    location_name.split.map(&:capitalize).join
  end
end

module NoWitnessStrategy
  include TweetStrategy

  private

  def structure
    %i[opening ghost_adjective ghost_noun preposition town_name location_name]
  end

  def opening
    ['Reports of', 'Sightings of'].sample
  end
end

module BreakingStoryStrategy
  include TweetStrategy

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

  def hash_tags
    "\##{town_hashtag} \#BREAKING"
  end
end

# module HistoricReportStrategy
#   include TweetStrategy

#   private

#   def structure
#     %i[this_day year ghost witness_past_verb preposition town_name]
#   end

#   def this_day
#     'On this day in'
#   end

#   def year
#     "#{random_year}:"
#   end

#   def ghost
#     "#{ghost_adjective.capitalize} #{ghost_noun}"
#   end

#   def random_year
#     Time.at(from_date + rand * (to_date.to_f - from_date.to_f)).year
#   end

#   def from_date
#     Time.local(1977, 1, 1)
#   end

#   def to_date
#     Time.now
#   end

#   def hash_tags
#     "\##{town_hashtag} \#OnThisDay"
#   end
# end

class Tweeter
  def run
    tweet = GhostReport.new(words: words, strategy: strategy).full_tweet
    loop do
      break if tweet.length <= 140
      tweet = GhostReport.new(words: words, strategy: strategy).full_tweet
    end
    client.update(tweet)
    # puts tweet
  end

  private

  def strategy
    [TweetStrategy, NoWitnessStrategy, BreakingStoryStrategy].sample
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
