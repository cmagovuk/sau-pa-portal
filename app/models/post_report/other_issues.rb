class PostReport::OtherIssues < PostReport
  validates :other_issues_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[other_issues other_issues_text other_issues_link].freeze
  end
end
