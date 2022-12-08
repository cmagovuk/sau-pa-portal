class Request::Beneficiary < Request
  BEN_ID_TYPE_OPTIONS = %w[comp charity vat utr].freeze
  BEN_SIZE_OPTIONS = %w[micro small medium large].freeze

  validates :ben_id, length: { maximum: 50 }
  validates :beneficiary, length: { maximum: 255 }
  validates :ben_id_type, presence: { if: ->(o) { o.ben_id.present? } }
  validate :validate_ben_id

  def validate_ben_id
    return if ben_id_type.blank? || ben_id.blank?

    errors.add(:ben_id, I18n.t("errors.attributes.ben_id.format.#{ben_id_type}")) unless id_type_regex.match(ben_id)
  end

  def id_type_regex
    case ben_id_type
    # 8 numbers or 2 letters followed by 6 numbers
    when "comp" then /^((\d{8})|([a-zA-Z]{2}\d{6}))\Z/
    # Up to 8 numbers
    when "charity" then /^\d{1,8}\Z/
    # nine digits long
    when "vat" then /^\d{9}\Z/
    # 10 digits long
    when "utr" then /^\d{10}\Z/
    else //
    end
  end

  def permitted
    %w[ben_id_type ben_id beneficiary ben_size].freeze
  end
end
