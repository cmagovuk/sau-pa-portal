class PostReport::PrincipleF < PostReport
  validates :pf_subsidy_char_text, length: { maximum: MAX_CHAR_COUNT }
  validates :pf_market_char_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[pf_subsidy_char pf_subsidy_char_text pf_market_char pf_market_char_text].freeze
  end
end
