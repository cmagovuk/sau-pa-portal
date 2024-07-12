class PostReport::ReferralDetails < PostReport
  validates :confi_issues_text, length: { maximum: MAX_CHAR_COUNT }
  validates :third_party_reps_text, length: { maximum: MAX_CHAR_COUNT }
  validates :reject_reason, length: { maximum: MAX_CHAR_COUNT }
  validates :withdrawn_reason, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[referral_name special_cats special_cats_text third_party_reps third_party_reps_text value confi_issues confi_issues_text reject_reason withdrawn_reason].freeze
  end
end
