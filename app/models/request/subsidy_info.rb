class Request::SubsidyInfo < Request
  attr_accessor :confirm_date_day, :confirm_date_month, :confirm_date_year

  validates :budget, numericality: { greater_than: 0, less_than: 10_000_000_000_000 }, allow_blank: true
  validates :other_form, length: { maximum: 255 }
  validate :validate_confirm_date

  delegate :pa_name, to: :public_authority

  SUBSIDY_FORM_OPTIONS = %w[dire equi gaur loan above below tax other].freeze

  def select_form_options
    [OpenStruct.new(name: "Select form type", id: "")] +
      SUBSIDY_FORM_OPTIONS.map do |id|
        OpenStruct.new(id: id, name: I18n.t(id&.to_sym, scope: [:subsidy_form_options]))
      end
  end

  def validate_confirm_date
    validate_date(:confirm_date)
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

  def permitted
    %w[subsidy_form other_form budget tax_amt confirm_date].freeze
  end
end
