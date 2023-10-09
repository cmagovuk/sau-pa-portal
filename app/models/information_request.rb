class InformationRequest < ApplicationRecord
  belongs_to :request

  has_many_attached :request_doc
  has_many_attached :response_doc

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

  def valid_request_documents?(docs)
    @valid_request_documents ||= validate_documents?(docs, request_doc)
  end

  def valid_response_documents?(docs)
    @valid_response_documents ||= validate_documents?(docs, response_doc)
  end

  def validate_documents?(docs, doc_set)
    all_valid = true
    docs.each_with_index do |doc, idx|
      doc_valid = !too_many_files?(docs, doc_set) && non_empty_file?(doc, idx) && valid_file_type?(doc, idx) && valid_file_extension?(doc, idx)
      all_valid &&= doc_valid
    end
    all_valid
  end

  def remove_request_doc(doc_id)
    document = request_doc.find(doc_id)
    document.purge
  rescue ActiveRecord::RecordNotFound
    # Document already removed, do nothing
  end

  def add_request_doc(doc)
    request_doc.attach(doc)
  end

  def remove_response_doc(doc_id)
    document = response_doc.find(doc_id)
    document.purge
  rescue ActiveRecord::RecordNotFound
    # Document already removed, do nothing
  end

  def add_response_doc(doc)
    response_doc.attach(doc)
  end

private

  def non_empty_file?(document, idx)
    return true unless document.size.zero?

    errors.add(
      "documents_#{idx}",
      I18n.t("errors.upload.multi_empty_file_error_message", filename: document.original_filename),
    )
    false
  end

  def too_many_files?(docs, doc_set)
    return false unless (docs.count + doc_set.count) > MAXIMUM_FILE_UPLOADS

    errors.add(:documents, I18n.t("errors.upload.too_many_files_error_message", file_uploads: MAXIMUM_FILE_UPLOADS))
    true
  end

  def valid_file_type?(document, idx)
    return true if CONTENT_TYPES_ALLOWED.include?(document.content_type)

    errors.add("documents_#{idx}", I18n.t("errors.upload.multi_file_type_error_message", filename: document.original_filename))
    false
  end

  def valid_file_extension?(document, idx)
    extension = File.extname(document.original_filename).downcase
    return true if EXTENSIONS_ALLOWED.include?(extension)

    errors.add("documents_#{idx}", I18n.t("errors.upload.file_type_error_message", filename: document.original_filename))
    false
  end
end
