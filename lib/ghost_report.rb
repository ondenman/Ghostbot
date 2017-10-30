# Represents a UK Ghost Report tweet
class GhostReport
  def initialize(words)
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

  def tweet
    [
      "#{sentence} #{hash_tags}",
      "#{sentence} #{additional_note} #{hash_tags}"
    ].sample
  end

  private

  attr_accessor :words

  def hash_tags
    "\##{town_name.delete(' ')} \##{town_name.delete(' ')}#{location_name.split.map(&:capitalize).join}"
  end

  def singular(plural)
    plural.to_s.chomp('s').to_sym
  end

  def sentence
    "#{sentence_structure.join(' ')}."
  end

  # TODO: Extract this to data file
  def sentence_structure
    [
      [
        witness,
        witness_present_verb,
        ghost_adjective,
        ghost_noun, preposition,
        town_name,
        location_name
      ],
      [
        ['Reports of', 'Sightings of'].sample,
        ghost_adjective,
        ghost_noun,
        preposition,
        town_name,
        location_name
      ],
      [
        'BREAKING:',
        ghost_adjective.capitalize,
        ghost_noun,
        'reported',
        preposition,
        town_name,
        location_name
      ]
    ].sample
  end

  def witness
    witness_noun.capitalize
  end
end
