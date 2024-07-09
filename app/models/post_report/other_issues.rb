class PostReport::OtherIssues < PostReport
  def permitted
    %w[other_issues other_issues_text].freeze
  end
end
