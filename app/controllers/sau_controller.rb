class SauController < ApplicationController
  def authorise_user
    render template: "errors/unauthorised", status: :unauthorized and return unless auth_user.is_sau_user?
  end

  def home_page_url
    sau_dashboard_index_path
  end

  helper_method :home_page_url
end
