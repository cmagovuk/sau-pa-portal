class Request::Dates < Request
  attr_accessor :confirm_date_day, :confirm_date_month, :confirm_date_year, :start_date_day, :start_date_month, :start_date_year, :end_date_day, :end_date_month, :end_date_year

  validate :validate_confirm_date
  validate :validate_start_date
  validate :validate_end_date
  validate :validate_end_after_start

  def permitted
    %w[confirm_date start_date end_date].freeze
  end

private

  def validate_confirm_date
    validate_date(:confirm_date)
  end

  def validate_start_date
    validate_date(:start_date)
  end

  def validate_end_date
    validate_date(:end_date)
  end

  def validate_end_after_start
    if end_date.present? && start_date.present? && (end_date < start_date)
      errors.add(:end_date, I18n.t("errors.dates.end_before_start"))
    end
  end

  def validate_date(date_field)
    date_args = date_array(date_field).map(&:strip)
    return send("#{date_field}=", "") if date_args.compact_blank.blank?

    validate_date_format(date_args, date_field)
    validate_year(date_field)
  end

  def validate_year(date_field)
    errors.add(date_field, I18n.t("errors.dates.full_year")) if errors[date_field].count.zero? && send(date_field).year < 1000
  end

  def validate_date_format(date_args, date_field)
    errors.add(date_field, "Date format invalid") unless convert_date(date_args, date_field)
  end

  def convert_date(date_args, date_field)
    return false if date_args.any?(&:nil?)
    return false if date_args.compact_blank.count < 3

    begin
      send("#{date_field}=", Date.civil(date_args[0].to_i, date_args[1].to_i, date_args[2].to_i))
    rescue ArgumentError
      false
    end
  end

  def date_array(date_field)
    [send("#{date_field}_year"), send("#{date_field}_month"), send("#{date_field}_day")]
  end
end
