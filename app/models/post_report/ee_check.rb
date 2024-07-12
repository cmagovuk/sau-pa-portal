class PostReport::EeCheck < PostReport
  def permitted
    %w[ee_required].freeze
  end
end
