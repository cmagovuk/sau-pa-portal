class PostReport::ReferralDetails < PostReport
  validates :confi_issues_text, length: { maximum: MAX_CHAR_COUNT }
  validates :third_party_reps_text, length: { maximum: MAX_CHAR_COUNT }
  validates :reject_reason, length: { maximum: MAX_CHAR_COUNT }
  validates :withdrawn_reason, length: { maximum: MAX_CHAR_COUNT }
  validates :value, numericality: { greater_than: 0, less_than: 10_000_000_000_000 }, allow_blank: true
  validates :referral_name, length: { maximum: 255 }
  validates :assist_director, length: { maximum: 255 }
  validates :principle_adviser, length: { maximum: 255 }
  validates :final_report_url, length: { maximum: 255 }
  validate :final_report_url_format

  def final_report_url_format
    return if final_report_url.blank?

    uri = as_uri(final_report_url)
    errors.add(:final_report_url, :format) unless uri.present? && uri.scheme == "https" && uri.host.present?
  end

  def as_uri(value)
    parse_uri(value) if value.present?
  end

  def parse_uri(value)
    URI.parse(value.to_s)
  rescue URI::InvalidURIError
    nil
  end

  def permitted
    [:referral_name,
     :special_cats,
     :third_party_reps,
     :third_party_reps_text,
     :value,
     :confi_issues,
     :confi_issues_text,
     :reject_reason,
     :withdrawn_reason,
     :intl_obligations,
     :final_report_url,
     :principle_adviser,
     :assist_director,
     { special_cat_values: [] },
     { intl_obligation_values: [] }].freeze
  end
end
