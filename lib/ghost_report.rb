# Represents a UK Ghost Report tweet
class GhostReport
  def initialize(words)
    words.keys.each do |k|
      define_singleton_method(singular(k), -> { words[k].sample })
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
    "\##{town.delete(' ')} \##{town.delete(' ')}#{location.split.map(&:capitalize).join}"
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
        town,
        location
      ],
      [
        ['Reports of', 'Sightings of'].sample,
        ghost_adjective,
        ghost_noun,
        preposition,
        town,
        location
      ],
      [
        'Hauntings',
        %w[reported recorded].sample,
        preposition,
        town,
        location
      ],
      [
        'BREAKING:',
        ghost_adjective.capitalize,
        ghost_noun,
        'reported',
        preposition,
        town,
        location
      ]
    ].sample
  end

  def witness
    witness_noun.capitalize
  end

  # Need to memoize these otherwise hash tag town and location
  # differ from those in main tweet content
  def town
    @town ||= town_name
  end

  def location
    @location ||= location_name
  end
end
