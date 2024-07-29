class PostReport::OtherIssues < PostReport
 URI_REGEX = /\A#{URI::Parser.new.make_regexp(%w[https])}\z/
  validates :other_issues_text, length: { maximum: MAX_CHAR_COUNT }
  validate :other_issues_link_format

  def other_issues_link_format
    return if other_issues_link.blank?
    uri = as_uri(other_issues_link)

    errors.add(:other_issues_link, :format) unless uri.present? && uri.scheme == "https" && uri.host.present?
  end

  def as_uri(value)
    URI.parse(value.to_s) rescue nil if value.present?
  end

  def permitted
    %w[other_issues other_issues_text other_issues_link].freeze
  end
end
