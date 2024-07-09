class PostReport::PrincipleE < PostReport
  def permitted
    %w[pe_policy pe_policy_text pe_other_means pe_other_means_text].freeze
  end
end
