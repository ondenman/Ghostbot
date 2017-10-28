require 'pry'
require 'twitter'

Dir['./lib/*.rb'].each { |file| require file }

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end

class Tweeter
  def run
    rep = GhostReport.new(words)
    client.update(rep.tweet) if rep.tweet.length <= 144
    # puts rep.tweet
  end

  private

  def words
    @words ||= Dir['./data/*'].inject({}) do |h, file|
      h.merge(File.basename(file).to_sym => lines(file))
    end
  end

  def lines(file)
    File.readlines(file).map(&:chomp).reject(&:empty?)
  end
end

tweeter = Tweeter.new
tweeter.run

# Every half hour, one in three chance of posting tweet
loop do
  sleep 1800
  tweeter.run if Random.rand(3) == 0
end
