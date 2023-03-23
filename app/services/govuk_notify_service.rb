class GovukNotifyService
  require "notifications/client"

  def self.send_submit_request_email(request, auth_user)
    template_name = case request.referral_type
                    when "par" then :submit_par
                    when "soi" then :submit_int_request
                    when "ssi" then :submit_int_request
                    else :submit_request
                    end

    template_id = Rails.application.config.govuk_notify_templates.fetch(template_name)
    if api_key.present? && template_id.present?
      notify_client.send_email(
        email_address: auth_user.email,
        template_id: template_id,
        personalisation: {
          submitter_name: auth_user.name,
          reference_number: request.reference_number,
        },
      )
    end
  rescue Notifications::Client::BadRequestError => e
    # silently ignore failure to send email
    Rails.logger.warn "Failed to send email #{e.message}"
  end

  def self.send_called_in_email(request)
    template_id = Rails.application.config.govuk_notify_templates.fetch(:call_in)
    if api_key.present? && template_id.present?
      notify_client.send_email(
        email_address: request.user.email,
        template_id: template_id,
        personalisation: {
          link_url: "#{Rails.application.config.pap_url}/dashboard",
          reference_number: request.reference_number,
        },
      )
    end
  rescue Notifications::Client::BadRequestError => e
    # silently ignore failure to send email
    Rails.logger.warn "Failed to send email #{e.message}"
  end

  def self.send_rfi_response_email(request, email_address)
    template_id = Rails.application.config.govuk_notify_templates.fetch(:rfi_response)
    if api_key.present? && template_id.present?
      notify_client.send_email(
        email_address: email_address,
        template_id: template_id,
        personalisation: {
          reference_number: request.reference_number,
        },
      )
    end
  rescue Notifications::Client::BadRequestError => e
    # silently ignore failure to send email
    Rails.logger.warn "Failed to send email #{e.message}"
  end

  def self.send_request_withdraw_email(request, email_address)
    template_id = Rails.application.config.govuk_notify_templates.fetch(:request_withdraw)
    if api_key.present? && template_id.present?
      notify_client.send_email(
        email_address: email_address,
        template_id: template_id,
        personalisation: {
          reference_number: request.reference_number,
        },
      )
    end
  rescue Notifications::Client::BadRequestError => e
    # silently ignore failure to send email
    Rails.logger.warn "Failed to send email #{e.message}"
  end

  def self.send_rfi_request_email(email_address, request, _link_path)
    template_id = Rails.application.config.govuk_notify_templates.fetch(:submit_rfi_request)
    if api_key.present? && template_id.present? && email_address.present?
      notify_client.send_email(
        email_address: email_address,
        template_id: template_id,
        personalisation: {
          # link_url: "#{Rails.application.config.pap_url}#{link_path}",
          link_url: "#{Rails.application.config.pap_url}/dashboard",
          reference_number: request.reference_number,
        },
      )
    end
  rescue Notifications::Client::BadRequestError => e
    # silently ignore failure to send email
    Rails.logger.warn "Failed to send email #{e.message}"
  end

  def self.send_status_changed_email(request, _link_path, status)
    template_id = Rails.application.config.govuk_notify_templates.fetch(:request_status_changed).fetch(status)
    if api_key.present? && template_id.present?
      pa_su_users = request.public_authority.users.active_users.super_users.select(:email).map(&:email)
      notify_users = pa_su_users.union([request.submitted_by.email]) if request.submitted_by.present? && request.submitted_by.disabled.blank?
      notify_users.map do |email|
        notify_client.send_email(
          email_address: email,
          template_id: template_id,
          personalisation: {
            link_url: "#{Rails.application.config.pap_url}/dashboard",
            reference_number: request.reference_number,
          },
        )
      end
    end
  rescue Notifications::Client::BadRequestError => e
    # silently ignore failure to send email
    Rails.logger.warn "Failed to send email #{e.message}"
  end

  def self.send_user_invite_email(user)
    template_id = Rails.application.config.govuk_notify_templates.fetch(:user_invitation)
    if api_key.present? && template_id.present?
      notify_client.send_email(
        email_address: user.email,
        template_id: template_id,
        personalisation: {
          link_url: Rails.application.config.pap_url,
          name: user.user_name,
        },
      )
    end
  rescue Notifications::Client::BadRequestError => e
    # silently ignore failure to send email
    Rails.logger.warn "Failed to send email #{e.message}"
  end

  private_class_method def self.notify_client
    @notify_client || Notifications::Client.new(api_key)
  end

  private_class_method def self.api_key
    @api_key || ENV["GOVUK_NOTIFY_API_KEY"]
  end
end
