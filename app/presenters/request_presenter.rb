class RequestPresenter
  def initialize(request)
    @request = request
  end

  def view_path
    "/requests/view/#{@request.id}"
  end

  def actions(auth_user)
    actions = []
    if @request.internal_state.present? && @request.internal_state.include?("info-required") && @request.status == "Accepted"
      rfis = @request.information_requests.select { |x| x.status == "request-confirmed" }
      if rfis.count.positive?
        actions += [{ title: "Provide further information", link: "/information_responses/#{rfis[0].id}", secondary: false }]
      end
    end
    actions += [{ title: "View submission", link: view_path, secondary: actions.count.positive? }]
    if %w[Declined Rejected].include?(@request.status)
      actions += [{ title: "Called in", link: "/call_in_direction/#{@request.id}", secondary: true }]
    end
    if @request.referral_type != "par" && %w[Submitted Accepted].include?(@request.status) && auth_user.is_pa_super_user?
      actions += [{ title: "Withdraw", link: "/request_withdraw/#{@request.id}", secondary: true }]
    end
    if @request.referral_type != "par" || @request.par_on_td != "y"
      actions += [{ title: "Export for BEIS database", link: "/requests/#{@request.id}.xlsx", secondary: true }]
    end
    actions
  end

  def info_actions
    @info_actions ||= {
      "request-confirmed" => request_confirmed_action,
      "response-confirmed" => { link: nil, tag_text: "Completed", colour: nil },
      "request-unconfirmed" => { link: nil, tag_text: "Request incomplete", colour: "red" },
      "response-unconfirmed" => { link: "/information_responses/:id/confirm", tag_text: "Response incomplete", colour: "red" },
    }.freeze
  end

private

  def request_confirmed_action
    return { link: "/information_responses/:id", tag_text: "Info required", colour: "red" } if @request.status == "Accepted"

    { link: nil, tag_text: "", colour: nil }
  end
end
