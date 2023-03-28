class Request::SchemeInfo < Request
  validates :budget, numericality: { greater_than: 0, less_than: 10_000_000_000_000 }, allow_blank: true
  validates :max_amt_s, length: { maximum: 255 }
  validates :scheme_name, length: { maximum: 255 }
  validate :validate_int_value
  validate :validate_word_count

  with_options unless: -> { referral_type == "par" && par_on_td == "y" } do
    validates :scheme_name, presence: true
  end

  delegate :pa_name, to: :public_authority

  def validate_int_value
    errors.add(:budget, :not_an_integer) if budget.present? && budget.to_i != budget
  end

  def validate_word_count
    errors.add(:emergency_desc, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(emergency_desc)
  end

  def permitted
    %w[scheme_name budget max_amt_s is_emergency emergency_desc].freeze
  end
end
