class Request::RequestWithdraw < Request
  CONTENT_TYPES_ALLOWED = %w[
    application/pdf
    application/msword
    application/vnd.ms-excel
    application/vnd.ms-powerpoint
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.openxmlformats-officedocument.presentationml.presentation
    application/zip
  ].freeze

  EXTENSIONS_ALLOWED = %w[.doc .docx .xls .xlsx .ppt .pptx .pdf .zip].freeze

  attr_accessor :continue_btn

  validate :validate_word_count

  with_options if: :continue_btn do
    validate :reason_or_document_present
  end

  def valid_document?(doc)
    @valid_document ||= !too_many_files? && valid_file_type?(doc) && non_empty_file?(doc) && valid_file_extension?(doc)
  end

  def add_document(doc)
    withdraw_document.attach(doc)
    return true if CONTENT_TYPES_ALLOWED.include?(withdraw_document.content_type)

    errors.add(:withdraw_document, I18n.t("errors.upload.file_type_error_message"))
    withdraw_document.purge
    false
  end

  def remove_document(*)
    withdraw_document.purge if withdraw_document.attached?
  end

private

  def validate_word_count
    errors.add(:withdraw_reason, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(withdraw_reason)
  end

  def reason_or_document_present
    if withdraw_reason.blank? && !withdraw_document.attached?
      errors.add(:withdraw_reason, I18n.t("errors.request_withdraw.blank_reason_and_document"))
    end
  end

  def valid_file_type?(document)
    return true if CONTENT_TYPES_ALLOWED.include?(document.content_type)

    errors.add(:withdraw_document, I18n.t("errors.upload.file_type_error_message"))
    false
  end

  def valid_file_extension?(document)
    extension = File.extname(document.original_filename).downcase
    return true if EXTENSIONS_ALLOWED.include?(extension)

    errors.add(:documents, I18n.t("errors.upload.file_type_error_message", filename: document.original_filename))
    false
  end

  def non_empty_file?(document)
    return true unless document.size.zero?

    errors.add(:withdraw_document, I18n.t("errors.upload.empty_file_error_message"))
    false
  end

  def too_many_files?
    return false unless withdraw_document.attached?

    errors.add(:withdraw_document, I18n.t("errors.upload.only_one_file_error_message"))
    true
  end
end
