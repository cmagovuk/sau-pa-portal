class Request::Sector < Request
  SECTOR_OPTIONS = %w[accom actex actho admin agric artse const educa elect finan human infor manuf minin other profe publi reale trans water whole].freeze

  def permitted
    %w[sectors].freeze
  end

  def sectors
    self[:sectors][1] if self[:sectors].present? && self[:sectors].count > 1
  end

  def sectors=(value)
    self[:sectors] = ["", value]
  end
end
