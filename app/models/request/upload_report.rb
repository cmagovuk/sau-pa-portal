class Request::UploadReport < Request
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

  MAXIMUM_FILE_UPLOADS = 100

  validate :atleast_one_file

  def valid_document?(doc)
    @valid_document ||= valid_file_type?(doc) && non_empty_file?(doc) && !too_many_files? && valid_file_extension?(doc)
  end

  def add_document(doc)
    final_report.attach(doc)
  end

  def remove_document(doc_id)
    document = final_report.find(doc_id)
    document.purge
  rescue ActiveRecord::RecordNotFound
    # Document already removed, do nothing
  end

  def atleast_one_file
    errors.add(:final_report, I18n.t("errors.upload.no_file_error_message")) if final_report.count.zero?
  end

private

  def non_empty_file?(document)
    return true unless document.size.zero?

    errors.add(
      :final_report,
      I18n.t("errors.upload.empty_file_error_message"),
    )
    false
  end

  def too_many_files?
    return false unless final_report.count >= MAXIMUM_FILE_UPLOADS

    errors.add(:final_report, I18n.t("errors.upload.too_many_files_error_message", file_uploads: MAXIMUM_FILE_UPLOADS))
    true
  end

  def valid_file_type?(document)
    return true if CONTENT_TYPES_ALLOWED.include?(document.content_type)

    errors.add(:final_report, I18n.t("errors.upload.file_type_error_message", filename: document.original_filename))
    false
  end

  def valid_file_extension?(document)
    extension = File.extname(document.original_filename).downcase
    return true if EXTENSIONS_ALLOWED.include?(extension)

    errors.add(:documents, I18n.t("errors.upload.file_type_error_message", filename: document.original_filename))
    false
  end
end
