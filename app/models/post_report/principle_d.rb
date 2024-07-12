class PostReport::PrincipleD < PostReport
  validates :pd_additionality_text, length: { maximum: MAX_CHAR_COUNT }
  validates :pd_costs_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[pd_additionality pd_additionality_text pd_costs pd_costs_text].freeze
  end
end
