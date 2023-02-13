class AdminController < ApplicationController
  def authorise_user
    render template: "errors/unauthorised", status: :unauthorized unless auth_user.has_role?("SAU-Admin")
  end

  def home_page_url
    sau_dashboard_index_path
  end

  def maintenance_text
    @maintenance_text = ""
  end
end
