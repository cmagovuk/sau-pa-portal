class PostReport::EePrinciples < PostReport
  def permitted
    %w[ee_principles ee_principles_text ee_issues ee_issues_text].freeze
  end
end
