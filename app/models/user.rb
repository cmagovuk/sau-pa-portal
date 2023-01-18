class User < ApplicationRecord
  EMAIL_REGEX = /\A(?!\.)("([^"\r\\]|\\["\r\\])*"|([-a-zA-Z0-9!#$%&'*+\/=?^_`{|}~]|(?<!\.)\.)*)(?<!\.)@[a-zA-Z0-9][\w.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z.]*[a-zA-Z]\z/.freeze
  attr_writer :current_step

  belongs_to :public_authority
  has_many :audit_logs, as: :log

  USER_ROLE_OPTIONS = %w[su u].freeze

  validates :user_name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }, unless: -> { id.present? }
  validates :role, presence: true, inclusion: { in: USER_ROLE_OPTIONS }
  validates :phone, length: { maximum: 30 }

  def current_step
    @current_step || "input"
  end

  def confirm_step
    self.current_step = "confirm"
  end

  def last_step?
    current_step == "confirm"
  end
end
