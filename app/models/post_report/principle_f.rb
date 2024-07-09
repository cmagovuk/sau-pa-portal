class PostReport::PrincipleF < PostReport
  def permitted
    %w[pf_subsidy_char pf_subsidy_char_text pf_market_char pf_market_char_text].freeze
  end
end
