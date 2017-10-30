# Represents a UK Ghost Report tweet
class GhostReport
  def initialize(words:, decorator:)
    extend decorator

    words.each_key do |k|
      define_singleton_method(singular(k), lambda do
        if instance_variable_defined?("@#{k}")
          instance_variable_get("@#{k}")
        else
          instance_variable_set("@#{k}", words[k].sample)
        end
      end)
    end
  end

  def full_tweet
    [
      "#{tweet}. #{hash_tags}",
      "#{tweet}. #{additional_note} #{hash_tags}"
    ].sample
  end

  private

  attr_accessor :words, :sentence_structure

  def hash_tags
    "\##{town_hashtag} \##{town_hashtag}#{location_hashtag}"
  end

  def town_hashtag
    town_name.gsub(/[^0-9a-z ]/i, '')
  end

  def location_hashtag
    location_name.split.map(&:capitalize).join
  end

  def singular(plural)
    plural.to_s.chomp('s').to_sym
  end
end
