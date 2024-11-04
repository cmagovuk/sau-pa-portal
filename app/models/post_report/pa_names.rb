class PostReport::PaNames < PostReport
  def permitted
    [{ pa_names: [] }].freeze
  end
end
