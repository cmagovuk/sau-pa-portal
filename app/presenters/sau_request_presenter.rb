class SauRequestPresenter
  def initialize(request)
    @request = request
  end

  def view_path
    "/sau_requests/view/#{@request.id}"
  end

  def actions(auth_user)
    actions = []
    if auth_user.has_role?("SAU-Pipeline")
      if @request.status == "Submitted" || (@request.status == "Pending withdrawal" && @request.internal_state.include?("Submitted"))
        actions += [
          { title: "Set decision", link: "/set_decision/#{@request.id}", secondary: false },
        ]
      end

      if @request.status == "Accepted" || (@request.status == "Pending withdrawal" && @request.internal_state.include?("Accepted"))
        actions += [
          { title: "Upload report", link: "/sau_requests/#{@request.id}/report", secondary: false },
          # { title: "Withdraw", link: "/withdraw/#{@request.id}", secondary: true },
        ]
        unless @request.internal_state.present? && @request.internal_state.include?("info_required")
          rfis = @request.information_requests.reject { |x| x.status == "response-confirmed" }
          if rfis.count.zero?
            actions += [
              { title: "Initiate RFI", link: "/sau_requests/#{@request.id}/information_requests/new", secondary: true },
            ]
          end
        end

        if @request.referral_type != "par" && @request.referral_type != "call"
          actions += [
            { title: "Called in", link: "/call_in/#{@request.id}", secondary: true },
          ]
        end
      end

      if @request.status == "Pending withdrawal" || (@request.referral_type == "par" && %w[Submitted Accepted].include?(@request.status))
        actions += [
          { title: "Withdraw", link: "/withdraw/#{@request.id}", secondary: true },
        ]
      end
    end

    actions += [{ title: "View submission", link: view_path, secondary: actions.count.positive? }]
    actions
  end

  def info_actions
    @info_actions ||= {
      "request-confirmed" => { link: false, tag_text: "Info required", colour: "red" },
      "response-confirmed" => { link: false, tag_text: "Completed", colour: nil },
      "request-unconfirmed" => { link: "/information_requests/:id/confirm", tag_text: "Request incomplete", colour: "red" },
      "response-unconfirmed" => { link: false, tag_text: "Info required", colour: "red" },
    }.freeze
  end
end
