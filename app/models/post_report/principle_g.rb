class PostReport::PrincipleG < PostReport
  validates :pg_balance_uk_text, length: { maximum: MAX_CHAR_COUNT }
  validates :pg_balance_intl_text, length: { maximum: MAX_CHAR_COUNT }

  def permitted
    %w[pg_balance_uk pg_balance_uk_text pg_balance_intl pg_balance_intl_text].freeze
  end
end
