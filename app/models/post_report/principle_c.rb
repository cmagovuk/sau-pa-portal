class PostReport::PrincipleC < PostReport
  validates :pc_counterfactual_text, length: { maximum: MAX_CHAR_COUNT }
  validates :pc_eco_behaviour_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[pc_counterfactual pc_counterfactual_text pc_eco_behaviour pc_eco_behaviour_text].freeze
  end
end
