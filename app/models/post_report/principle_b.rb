class PostReport::PrincipleB < PostReport
  def permitted
    %w[pb_proportion pb_proportion_text].freeze
  end
end
