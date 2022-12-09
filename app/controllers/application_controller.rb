class ApplicationController < ActionController::Base
  before_action :authorise_user
  before_action :scheduled_maintenance
  before_action :set_headers

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def maintenance_text
    @maintenance_text ||= Rails.application.config.x.maintenance_text
  end

  def feedback_link
    @feedback_link ||= Rails.application.config.feedback_link
  end

  def home_page_url
    "/dashboard"
  end

  helper_method :maintenance_text, :home_page_url, :feedback_link

  def auth_user
    @auth_user ||= AuthUser.new(request)
  end
  helper_method :auth_user

  def set_headers
    response.set_header("X-Robots-Tag", "noindex, nofollow")
    response.set_header("Cache-Control", "max-age=0, no-cache, no-store, must-revalidate, private")
  end

private

  def scheduled_maintenance
    render template: "errors/service_unavailable", status: :service_unavailable unless maintenance_text.empty?
  end

  def authorise_user
    render template: "errors/unauthorised", status: :unauthorized unless auth_user.is_authorised?
  end
end
