class PostReport::EePrinciples < PostReport
  validates :ee_principles_text, length: { maximum: MAX_CHAR_COUNT }
  validates :ee_issues_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[ee_principles ee_principles_text ee_issues ee_issues_text].freeze
  end
end
