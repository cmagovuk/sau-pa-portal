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

      if %w[Completed Rejected Decined Withdrawn].include?(@request.status) &&
          !(@request.post_report.present? && @request.post_report.status == "Completed")
        actions += [
          { title: "Submit lessons learned", link: "/post_reports/#{@request.id}/edit", secondary: false },
        ]
      end
    end

    actions += [{ title: "View submission", link: view_path, secondary: actions.count.positive? }]

    if @request.post_report.present? && @request.post_report.status == "Completed"
      actions += [{ title: "View lessons learned",
                    secondary: actions.count.positive?,
                    link: "/sau_requests/#{@request.id}/view_post_report" }]
    end
    actions
  end

  def info_actions(auth_user)
    @info_actions ||= determine_info_actions(auth_user)
  end

  def determine_info_actions(auth_user)
    actions = {
      "response-confirmed" => { link: false, tag_text: "Completed", colour: nil },
      "request-unconfirmed" => { link: "/information_requests/:id/confirm", tag_text: "Request incomplete", colour: "red" },
      "response-unconfirmed" => { link: false, tag_text: "Awaiting info", colour: "red" },
    }

    actions["request-confirmed"] = if auth_user.has_role?("SAU-Pipeline")
                                     { link: "/information_requests/:id/amend", tag_text: "Amend docs", colour: "red" }
                                   else
                                     { link: false, tag_text: "Awaiting info", colour: "red" }
                                   end
    actions.freeze
    actions
  end
end
