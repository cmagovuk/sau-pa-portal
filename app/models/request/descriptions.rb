class Request::Descriptions < Request
  CONF_OPTIONS = %w[yes no].freeze
  EMAIL_REGEX = /\A(?!\.)("([^"\r\\]|\\["\r\\])*"|([-a-zA-Z0-9!#$%&'*+\/=?^_`{|}~]|(?<!\.)\.)*)(?<!\.)@[a-zA-Z0-9][\w.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z.]*[a-zA-Z]\z/.freeze

  # validates :description, length: { maximum:5000 }
  # validates :is_nc, presence: true
  # validates :is_nc, inclusion: { in: CONF_OPTIONS }
  # validates :nc_description, presence: { if: ->(o) { o.is_nc == "no" } }

  validates :third_party_email, length: { maximum: 255 }, format: { with: EMAIL_REGEX }, allow_blank: true
  validate :validate_word_count

  def validate_word_count
    errors.add(:description, :too_long, count: 5000) if description.present? && description.gsub("\r\n", "\n").length > 5000
    errors.add(:nc_description, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(nc_description)
  end

  def permitted
    %w[description is_nc nc_description third_party_email].freeze
  end
end
