class PostReport::PrincipleG < PostReport
  def permitted
    %w[pg_balance_uk pg_balance_uk_text pg_balance_intl pg_balance_intl_text].freeze
  end
end