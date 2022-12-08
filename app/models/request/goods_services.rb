class Request::GoodsServices < Request
  OPTIONS = %w[goods services].freeze

  def permitted
    [ben_good_svr: []].freeze
  end
end
