module RequestsHelper
  def select_filter_options(array)
    [["No filter", ""]] +
      array.map do |id|
        [id, id]
      end
  end

  def action_link(request)
    if request.status.blank? || request.status == "Draft"
      link_to "Continue", "/requests/reload/#{request.id}", method: :post, class: "govuk-link"
    elsif request.status == "Completed"
      link_to "View report", request_path(request), class: "govuk-link"
    elsif request.internal_state == "info-required"
      link_to "Info required", request_path(request), class: "govuk-link"
    else
      link_to "View", request_path(request), class: "govuk-link"
    end
  end

  def view_path(request)
    "/requests/view/#{request.id}"
  end

  def further_info_link(info, actions)
    if info.status.present?
      if actions[info.status][:tag_text].present?
        if actions[info.status][:link].present?
          link_to actions[info.status][:link].sub(":id", info.id), class: "govuk-link" do
            govuk_tag(text: actions[info.status][:tag_text], colour: actions[info.status][:colour])
          end
        else
          govuk_tag(text: actions[info.status][:tag_text], colour: actions[info.status][:colour])
        end
      end
    else
      link_to "#{information_request_path(info)}/request_confirm", class: "govuk-link" do
        govuk_tag(text: actions["request-uncomplete"][:tag_text], colour: actions["request-uncomplete"][:colour])
      end
    end
  end
end
