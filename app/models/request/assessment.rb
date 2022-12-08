class Request::Assessment < Request
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

  # Zip file content type application/zip

  MAXIMUM_FILE_UPLOADS = 30

  validate :validate_word_count

  def validate_word_count
    errors.add(:assess_pa, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(assess_pa)
    errors.add(:assess_pb, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(assess_pb)
    errors.add(:assess_pc, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(assess_pc)
    errors.add(:assess_pd, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(assess_pd)
    errors.add(:assess_pe, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(assess_pe)
    errors.add(:assess_pf, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(assess_pf)
    errors.add(:assess_pg, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(assess_pg)
  end

  def permitted
    %w[assess_pa assess_pb assess_pc assess_pd assess_pe assess_pf assess_pg].freeze
  end

  def upload_step?
    true
  end

  def valid_document?(doc)
    @valid_document ||= !too_many_files? && non_empty_file?(doc) && valid_file_type?(doc) && valid_file_extension?(doc)
  end

  def remove_document(doc_id)
    document = assessment_docs.find(doc_id)
    document.purge
  rescue ActiveRecord::RecordNotFound
    # Document already removed, do nothing
  end

  def add_document(doc)
    assessment_docs.attach(doc)
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

  def non_empty_file?(document)
    return true unless document.size.zero?

    errors.add(
      :documents,
      I18n.t("errors.upload.empty_file_error_message"),
    )
    false
  end

  def too_many_files?
    return false unless assessment_docs.count >= MAXIMUM_FILE_UPLOADS

    errors.add(:documents, I18n.t("errors.upload.too_many_files_error_message", file_uploads: MAXIMUM_FILE_UPLOADS))
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
end
