class Request::PartThree < Request
  PART_OPTIONS = %w[no yes].freeze

  validate :validate_word_count

  def validate_word_count
    errors.add(:p3_description, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(p3_description)
  end

  def permitted
    %w[is_p3_relevant p3_description].freeze
  end
end
