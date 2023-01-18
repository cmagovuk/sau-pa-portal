class SuperUserController < ApplicationController
  def authorise_user
    render template: "errors/unauthorised", status: :unauthorized and return unless auth_user.is_pa_super_user?
  end

  def home_page_url
    dashboard_path
  end

  helper_method :home_page_url
end
