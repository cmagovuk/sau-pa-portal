class SauUserForm
  include ActiveModel::Model

  EMAIL_REGEX = /\A(?!\.)("([^"\r\\]|\\["\r\\])*"|([-a-zA-Z0-9!#$%&'*+\/=?^_`{|}~]|(?<!\.)\.)*)(?<!\.)@[a-zA-Z0-9][\w.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z.]*[a-zA-Z]\z/

  attr_accessor :email_addr, :group

  validates :email_addr, presence: true, length: { maximum: 255 }, format: { with: EMAIL_REGEX }
end
