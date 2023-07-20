class Request::ReportDueDate < Request
  validates :report_due_date, presence: true
  validate :report_due_date_connot_be_in_the_past
  #  validate :report_due_date_connot_be_in_far_future

  MAX_DAYS_AHEAD = 30

private

  def report_due_date_connot_be_in_the_past
    errors.add(:report_due_date, I18n.t("errors.attributes.report_due_date.in_past")) if report_due_date.present? && report_due_date < Time.zone.today
  end

  def report_due_date_connot_be_in_far_future
    errors.add(:report_due_date, I18n.t("errors.attributes.report_due_date.in_future")) if report_due_date.present? && report_due_date > Time.zone.today.days_since(MAX_DAYS_AHEAD)
  end
end
