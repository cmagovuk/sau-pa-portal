class SauTeamController < ApplicationController
  def authorise_user
    render template: "errors/unauthorised", status: :unauthorized and return unless auth_user.has_role?("SAU-Pipeline") || auth_user.has_role?("SAU-Casework")

    render template: "errors/unauthorised", status: :unauthorized unless auth_user.case_access?(request_id)
  end

  def home_page_url
    sau_request_path(request_id)
  end

  helper_method :home_page_url

  def request_id
    nil
  end
end
