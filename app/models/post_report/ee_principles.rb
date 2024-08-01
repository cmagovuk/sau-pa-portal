class PostReport::EePrinciples < PostReport
  validates :ee_issues_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    [:ee_issues, :ee_issues_text, { ee_principles: [] }].freeze
  end
end
