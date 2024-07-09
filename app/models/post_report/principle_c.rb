class PostReport::PrincipleC < PostReport
  def permitted
    %w[pc_counterfactual pc_counterfactual_text pc_eco_behaviour pc_eco_behaviour_text].freeze
  end
end
