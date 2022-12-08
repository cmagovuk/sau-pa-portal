class Request::ParAssessment < Request
  validate :validate_word_count

  def validate_word_count
    errors.add(:par_reason, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(par_reason)
  end

  def permitted
    %w[par_assessed par_reason].freeze
  end
end
