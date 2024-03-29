class ErrorsController < ApplicationController
  skip_before_action :scheduled_maintenance
  layout "application"

  def unauthorised
    respond_to do |format|
      format.html { render status: :unauthorised }
      format.json { render json: { error: "Not authorised" }, status: :unauthorised }
      format.all { render status: :unauthorised, body: nil }
    end
  end

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.json { render json: { error: "Unprocessable entity" }, status: :unprocessable_entity }
    end
  end

  def service_unavailable
    respond_to do |format|
      format.html { render status: :service_unavailable }
      format.json { render json: { error: "Service unavailable" }, status: :service_unavailable }
    end
  end
end
