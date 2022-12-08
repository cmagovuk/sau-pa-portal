class AdminController < ApplicationController
  def authorise_user
    render template: "errors/unauthorised", status: :unauthorized unless auth_user.has_role?("SAU-Admin")
  end

  def maintenance_text
    @maintenance_text = ""
  end
end
