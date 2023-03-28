class Request::ChapterTwo < Request
  CHAPTER_OPTIONS = %w[no yes].freeze

  # validates :c2_description, length: { maximum:5000 }
  # validates :is_c2_relevant, presence: true
  # validates :is_c2_relevant, inclusion: { in: CHAPTER_OPTIONS }
  # validates :c2_description, presence: { if: ->(o) { o.is_c2_relevant == "yes" } }

  validate :validate_word_count

  def validate_word_count
    errors.add(:c2_description, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(c2_description)
  end

  def permitted
    %w[is_c2_relevant c2_description].freeze
  end
end
