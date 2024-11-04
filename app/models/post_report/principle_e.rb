class PostReport::PrincipleE < PostReport
  validates :pe_policy_text, length: { maximum: MAX_CHAR_COUNT }
  validates :pe_other_means_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[pe_policy pe_policy_text pe_other_means pe_other_means_text].freeze
  end
end
