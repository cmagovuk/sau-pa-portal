class AuditLog < ApplicationRecord
  belongs_to :log, polymorphic: true

  def self.log(user, event_type, **attrs)
    message = I18n.t "audit_log.#{event_type}", attrs
    { user_name: user.name, user_email: user.email, message: message, event_type: event_type, public_authority_id: user.pa_id }
  end
end
