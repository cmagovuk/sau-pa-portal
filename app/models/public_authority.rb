class PublicAuthority < ApplicationRecord
  before_validation :strip_blanks

  has_many :users
  has_many :audit_logs, as: :log
  has_many :sub_authorities, class_name: "PublicAuthority", foreign_key: "umbrella_authority_id"

  belongs_to :umbrella_authority, class_name: "PublicAuthority", optional: true

  validates :pa_name, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  scope :no_umbrella, -> { where umbrella_authority_id: nil }

private

  def strip_blanks
    self.pa_name = pa_name.strip if pa_name.present?
  end
end
