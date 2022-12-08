class PublicAuthority < ApplicationRecord
  before_validation :strip_blanks

  has_many :users
  has_many :audit_logs, as: :log

  validates :pa_name, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

private

  def strip_blanks
    self.pa_name = pa_name.strip if pa_name.present?
  end
end
