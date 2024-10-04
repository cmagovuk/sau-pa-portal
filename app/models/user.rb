class User < ApplicationRecord
  before_validation :strip_blanks

  EMAIL_REGEX = /\A(?!\.)("([^"\r\\]|\\["\r\\])*"|([-a-zA-Z0-9!#$%&'*+\/=?^_`{|}~]|(?<!\.)\.)*)(?<!\.)@[a-zA-Z0-9][\w.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z.]*[a-zA-Z]\z/
  attr_writer :current_step

  belongs_to :public_authority
  has_many :audit_logs, as: :log

  USER_ROLE_OPTIONS = %w[ga su u].freeze

  validates :user_name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }, unless: -> { id.present? }
  validates :role, presence: true, inclusion: { in: USER_ROLE_OPTIONS }
  validates :phone, length: { maximum: 30 }
  validate :pa_role_combination

  scope :active_users, -> { where disabled: nil }
  scope :super_users, -> { where role: "su" }

  def current_step
    @current_step || "input"
  end

  def confirm_step
    self.current_step = "confirm"
  end

  def last_step?
    current_step == "confirm"
  end

  def pa_role_combination
    has_sub_authorities = PublicAuthority.where(umbrella_authority: public_authority_id).count.positive?
    errors.add(:role, :must_be_ga) if has_sub_authorities && role != "ga"
    errors.add(:role, :must_not_be_ga) if !has_sub_authorities && role == "ga"
  end

private

  def strip_blanks
    self.email = email.strip if email.present?
  end
end
