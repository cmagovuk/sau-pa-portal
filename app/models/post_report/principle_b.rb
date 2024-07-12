class PostReport::PrincipleB < PostReport
  validates :pb_proportion_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[pb_proportion pb_proportion_text].freeze
  end
end
