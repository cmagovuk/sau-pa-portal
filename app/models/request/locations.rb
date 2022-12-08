class Request::Locations < Request
  OPTIONS = %w[noea nowe york emid wmid east lond soea sowe scot wales ni].freeze

  validate :validate_word_count

  def validate_word_count
    errors.add(:other_loc, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(other_loc)
  end

  def permitted
    [:other_loc, { location: [] }].freeze
  end
end
