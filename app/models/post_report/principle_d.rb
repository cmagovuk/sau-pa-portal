class PostReport::PrincipleD < PostReport
  def permitted
    %w[pd_additionality pd_additionality_text pd_costs pd_costs_text].freeze
  end
end
