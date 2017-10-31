# Represents a UK Ghost Report tweet
class GhostReport
  def initialize(words:, strategy:)
    extend strategy

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
      "#{tweet}. #{additional_note}"
    ].sample
  end

  private

  attr_accessor :words, :sentence_structure

  def singular(plural)
    plural.to_s.chomp('s').to_sym
  end
end
