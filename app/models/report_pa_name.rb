class ReportPaName < ApplicationRecord
  before_validation :strip_blanks

  validates :pa_name, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  scope :active_names, -> { where disabled: nil }

private

  def strip_blanks
    self.pa_name = pa_name.strip if pa_name.present?
  end
end
