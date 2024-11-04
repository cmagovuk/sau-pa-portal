class GaRequestPresenter
  def initialize(request)
    @request = request
  end

  def view_path
    "/requests/view/#{@request.id}"
  end

  def actions(_auth_user)
    actions = []
    actions += [{ title: "View submission", link: view_path, secondary: actions.count.positive? }]
    actions
  end

  def info_actions(_auth_user)
    @info_actions ||= {
      "request-confirmed" => request_confirmed_action,
      "response-confirmed" => { link: nil, tag_text: "Completed", colour: nil },
      "request-unconfirmed" => { link: nil, tag_text: "Request incomplete", colour: "red" },
      "response-unconfirmed" => { link: nil, tag_text: "Response incomplete", colour: "red" },
    }.freeze
  end

private

  def request_confirmed_action
    return { link: nil, tag_text: "Info required", colour: "red" } if @request.status == "Accepted"

    { link: nil, tag_text: "", colour: nil }
  end
end
