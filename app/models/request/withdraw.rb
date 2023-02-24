class Request::Withdraw < Request
  attr_accessor :continue_btn

  with_options if: :continue_btn do
    validate :document_present
  end

  def valid_document?(doc)
    @valid_document ||= !too_many_files? && non_empty_file?(doc) && valid_file_type?(doc) && valid_file_extension?(doc)
  end

  def add_document(doc)
    sau_withdrawn_doc.attach(doc)
    return true if CONTENT_TYPES_ALLOWED.include?(sau_withdrawn_doc.content_type)

    errors.add(:sau_withdrawn_doc, I18n.t("errors.upload.file_type_error_message"))
    sau_withdrawn_doc.purge
    false
  end

  def remove_document(*)
    sau_withdrawn_doc.purge if sau_withdrawn_doc.attached?
  end

private

  def document_present
    errors.add(:sau_withdrawn_doc, I18n.t("errors.upload.no_file_error_message")) unless sau_withdrawn_doc.attached?
  end

  def validate_word_count
    errors.add(:sau_withdrawn_doc, :too_long, count: Request::MAX_WORDCOUNT) if field_too_long(sau_withdrawn_doc)
  end

  def valid_file_type?(document)
    return true if CONTENT_TYPES_ALLOWED.include?(document.content_type)

    errors.add(:sau_withdrawn_doc, I18n.t("errors.upload.file_type_error_message"))
    false
  end

  def valid_file_extension?(document)
    extension = File.extname(document.original_filename).downcase
    return true if EXTENSIONS_ALLOWED.include?(extension)

    errors.add(:sau_withdrawn_doc, I18n.t("errors.upload.file_type_error_message", filename: document.original_filename))
    false
  end

  def non_empty_file?(document)
    return true unless document.size.zero?

    errors.add(:sau_withdrawn_doc, I18n.t("errors.upload.empty_file_error_message"))
    false
  end

  def too_many_files?
    return false unless sau_withdrawn_doc.attached?

    errors.add(:sau_withdrawn_doc, I18n.t("errors.upload.only_one_file_error_message"))
    true
  end
end
