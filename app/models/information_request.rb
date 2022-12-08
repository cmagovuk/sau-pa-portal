class InformationRequest < ApplicationRecord
  belongs_to :request

  has_one_attached :request_doc
  has_one_attached :response_doc

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

  def valid_document?(doc)
    @valid_document ||= non_empty_file?(doc) && valid_file_type?(doc) && valid_file_extension?(doc)
  end

  def remove_request_doc(*)
    request_doc.purge if request_doc.attached?
  end

  def add_request_doc(doc)
    request_doc.attach(doc)
  end

  def remove_response_doc(*)
    response_doc.purge if response_doc.attached?
  end

  def add_response_doc(doc)
    response_doc.attach(doc)
  end

private

  def non_empty_file?(document)
    return true unless document.size.zero?

    errors.add(
      :documents,
      I18n.t("errors.upload.empty_file_error_message"),
    )
    false
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
end
