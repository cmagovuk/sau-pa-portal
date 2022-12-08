class Request::Sectors < Request
  SECTOR_OPTIONS = %w[accom actex actho admin agric artse const educa elect finan human infor manuf minin other profe publi reale trans water whole].freeze

  def permitted
    [sectors: []].freeze
  end
end
