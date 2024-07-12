class PostReport::PrincipleA < PostReport
  validates :pa_policy_evidence_text, length: { maximum: MAX_CHAR_COUNT }
  validates :pa_market_fail_text, length: { maximum: MAX_CHAR_COUNT }
  validates :pa_equity_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[pa_policy_evidence pa_policy_evidence_text pa_market_fail pa_market_fail_text pa_equity pa_equity_text].freeze
  end
end
