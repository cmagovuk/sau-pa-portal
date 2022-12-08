class Request::CallInDirection < Request
  CONTENT_TYPES_ALLOWED = %w[
    application/pdf
    application/vnd.ms-excel
    application/vnd.ms-powerpoint
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.openxmlformats-officedocument.presentationml.presentation
    application/zip
  ].freeze

  EXTENSIONS_ALLOWED = %w[.doc .docx .xls .xlsx .ppt .pptx .pdf .zip].freeze

  attr_accessor :direction_date_day, :direction_date_month, :direction_date_year

  validate :validate_direction_date
  validate :validate_full_year

  with_options if: :continue_btn do
    validates :direction_date, presence: true
    validate :validate_document_uploaded
  end

  def permitted
    %w[direction_date].freeze
  end

  def upload_step?
    true
  end

  def valid_document?(doc)
    doc.present? && !too_many_files? && non_empty_file?(doc) && valid_file_type?(doc) && valid_file_extension?(doc)
  end

  def remove_document(*)
    call_in.purge if call_in.attached?
  end

  def add_document(doc)
    call_in.attach(doc)
  end

private

  # def valid_file_size?(document)
  #   return true if document.size <= FILE_SIZE_LIMIT
  #
  #   errors.add(
  #     :documents,
  #     I18n.t(
  #       "errors.upload.file_size_error_message",
  #       filename: document.original_filename,
  #       size_limit: ActiveSupport::NumberHelper.number_to_human_size(FILE_SIZE_LIMIT),
  #     ),
  #   )
  #   false
  # end

  def validate_document_uploaded
    errors.add(:documents, I18n.t("errors.upload.missing.call_in")) unless call_in.attached?
  end

  def non_empty_file?(document)
    return true unless document.size.zero?

    errors.add(
      :documents,
      I18n.t("errors.upload.empty_file_error_message"),
    )
    false
  end

  def too_many_files?
    return false unless call_in.attached?

    errors.add(:documents, I18n.t("errors.upload.only_one_file_error_message"))
    true
  end

  def valid_file_type?(document)
    return true if CONTENT_TYPES_ALLOWED.include?(document.content_type)

    errors.add(:documents, I18n.t("errors.upload.file_type_error_message", filename: document.original_filename))
    false
  end

  def valid_file_extension?(document)
    extension = File.extname(document.original_filename).downcase
    return true if EXTENSIONS_ALLOWED.include?(extension)

    errors.add(:documents, I18n.t("errors.upload.file_type_error_message", filename: document.original_filename))
    false
  end

  def validate_full_year
    errors.add(:direction_date, I18n.t("errors.dates.full_year")) if direction_date_year.present? && direction_date.year < 1000
  end

  def validate_direction_date
    date_args = [direction_date_day, direction_date_month, direction_date_year]
    return self.direction_date = "" if date_args.compact.present? && date_args.any?(&:blank?)

    validate_start_date_format(date_args)
  end

  def convert_direction_date(date_args)
    return false if date_args.any?(&:nil?)

    begin
      self.direction_date = Date.civil(direction_date_year.to_i, direction_date_month.to_i, direction_date_day.to_i)
    rescue ArgumentError
      false
    end
  end

  def validate_start_date_format(date_args)
    errors.add(:direction_date, "Date invalid") unless convert_direction_date(date_args)
  end
end
