class Request::ReportDueDate < Request
  attr_accessor :report_due_date_day, :report_due_date_month, :report_due_date_year

  validate :validate_report_due_date
  validate :validate_full_year
  validate :report_due_date_connot_be_in_the_past
  validate :report_due_date_connot_be_in_far_future
  validates :report_due_date, presence: true

private

  def report_due_date_connot_be_in_the_past
    errors.add(:report_due_date, I18n.t("errors.attributes.report_due_date.in_past")) if report_due_date.present? && report_due_date < Time.zone.today
  end

  def report_due_date_connot_be_in_far_future
    calendar_days = 40
    errors.add(:report_due_date, I18n.t("errors.attributes.report_due_date.in_future")) if report_due_date.present? && report_due_date > Time.zone.today.days_since(calendar_days)
  end

  def validate_full_year
    errors.add(:report_due_date, I18n.t("errors.dates.full_year")) if report_due_date.present? && report_due_date_year.present? && report_due_date.year < 1000
  end

  def validate_report_due_date
    date_args = [report_due_date_day, report_due_date_month, report_due_date_year]
    return self.report_due_date = "" if date_args.compact.present? && date_args.any?(&:blank?)

    validate_date_format(date_args)
  end

  def convert_report_due_date(date_args)
    return false if date_args.any?(&:nil?)

    begin
      self.report_due_date = Date.civil(report_due_date_year.to_i, report_due_date_month.to_i, report_due_date_day.to_i)
    rescue ArgumentError
      false
    end
  end

  def validate_date_format(date_args)
    errors.add(:report_due_date, "Date invalid") unless convert_report_due_date(date_args)
  end
end
