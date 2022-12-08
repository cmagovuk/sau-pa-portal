class Request::InfoLocation < Request
  validate :validate_word_count

  def validate_word_count
    errors.add(:info_location, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(info_location)
  end

  def permitted
    %w[info_location].freeze
  end
end
