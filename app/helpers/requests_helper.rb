module RequestsHelper
  def select_filter_options(array)
    [["No filter", ""]] +
      array.map do |id|
        [id, id]
      end
  end

  def action_link(request)
    if request.status.blank? || request.status == "Draft"
      content_tag(:dd, class: "govuk-summary-list__actions govuk-!-padding-top-0 govuk-!-padding-bottom-0") do
        content_tag(:ul, class: "govuk-summary-list__actions-list") do
          concat(content_tag(:li, class: "govuk-summary-list__actions-list-item app-stack app-border-right-0") do
            concat govuk_link_to "Continue", "/requests/reload/#{request.id}", method: :post, no_visited_state: true
          end)
          concat(content_tag(:li, class: "govuk-summary-list__actions-list-item app-stack") do
            concat govuk_link_to "Delete", confirm_delete_request_path(request), no_visited_state: true
          end)
        end
      end
    elsif request.status == "Completed"
      govuk_link_to "View report", request_path(request), no_visited_state: true
    elsif request.internal_state.present? && request.internal_state.include?("info-required")
      govuk_link_to "Info required", request_path(request), no_visited_state: true
    else
      govuk_link_to "View", request_path(request), no_visited_state: true
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

  def date_colour(date)
    return "red" if Time.zone.today >= date.days_ago(2)
    return "yellow" if Time.zone.today >= date.days_ago(7)

    "blue"
  end
end
