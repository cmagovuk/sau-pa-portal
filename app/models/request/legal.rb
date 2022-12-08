class Request::Legal < Request
  validate :validate_word_count

  def validate_word_count
    errors.add(:legal, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(legal)
    errors.add(:policy, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(policy)
  end

  def permitted
    %w[legal policy].freeze
  end
end
