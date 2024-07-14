class PostReport::ReferralDetails < PostReport
  validates :confi_issues_text, length: { maximum: MAX_CHAR_COUNT }
  validates :third_party_reps_text, length: { maximum: MAX_CHAR_COUNT }
  validates :reject_reason, length: { maximum: MAX_CHAR_COUNT }
  validates :withdrawn_reason, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    [:referral_name,
     :special_cats,
     :third_party_reps,
     :third_party_reps_text,
     :value,
     :confi_issues,
     :confi_issues_text,
     :reject_reason,
     :withdrawn_reason,
     { special_cat_values: [] }].freeze
  end
end
