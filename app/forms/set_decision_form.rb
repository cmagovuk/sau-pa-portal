class SetDecisionForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment

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

  attribute :decision, :string, default: nil
  attribute :param
  attr_accessor :continue_btn

  OPTIONS = %w[accepted declined rejected].freeze

  delegate :decision_letter, to: :request

  with_options if: :continue_btn do
    validates :decision, presence: true
    validates :decision, inclusion: { in: OPTIONS }
    validate :validate_document_uploaded
  end

  def valid_document?(doc)
    doc.present? && !too_many_files? && non_empty_file?(doc) && valid_file_type?(doc) && valid_file_extension?(doc)
  end

  def add_document(doc)
    decision_letter.attach(doc)
  end

  def remove_document(*)
    decision_letter.purge if decision_letter.attached?
  end

  def request
    @request = Request.find(param)
  end

private

  def validate_document_uploaded
    errors.add(:documents, I18n.t("errors.upload.missing.decision_letter")) unless decision_letter.attached?
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

  def non_empty_file?(document)
    return true unless document.size.zero?

    errors.add(
      :documents,
      I18n.t("errors.upload.empty_file_error_message"),
    )
    false
  end

  def too_many_files?
    return false unless decision_letter.attached?

    errors.add(:documents, I18n.t("errors.upload.only_one_file_error_message"))
    true
  end
end
