class Request::CharacterDesc < Request
  CONTENT_TYPES_ALLOWED = %w[
    application/pdf
    application/vnd.ms-excel
    application/vnd.ms-powerpoint
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/vnd.openxmlformats-officedocument.presentationml.presentation
    application/zip
    application/x-zip-compressed
  ].freeze

  EXTENSIONS_ALLOWED = %w[.doc .docx .xls .xlsx .ppt .pptx .pdf .zip].freeze

  MAXIMUM_FILE_UPLOADS = 100

  validate :validate_word_count

  def validate_word_count
    errors.add(:character_desc, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(character_desc)
  end

  def permitted
    %w[character_desc].freeze
  end

  def upload_step?
    true
  end

  def valid_document?(docs)
    @valid_document |= validate_documents?(docs)
  end

  def validate_documents?(docs)
    all_valid = true
    docs.compact_blank.each_with_index do |doc, idx|
      doc_valid = !too_many_files?(docs) && non_empty_file?(doc, idx) && valid_file_type?(doc, idx) && valid_file_extension?(doc, idx)
      all_valid &&= doc_valid
    end
    all_valid
  end

  def remove_document(doc_id)
    document = character_desc_docs.find(doc_id)
    document.purge
  rescue ActiveRecord::RecordNotFound
    # Document already removed, do nothing
  end

  def add_document(doc)
    character_desc_docs.attach(doc)
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

  def non_empty_file?(document, idx)
    return true unless document.size.zero?

    errors.add(
      "documents_#{idx}",
      I18n.t("errors.upload.multi_empty_file_error_message", filename: document.original_filename),
    )
    false
  end

  def too_many_files?(docs)
    return false unless (character_desc_docs.count + docs.compact_blank.count) > MAXIMUM_FILE_UPLOADS

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
