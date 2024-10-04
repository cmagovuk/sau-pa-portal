class Request < ApplicationRecord
  has_one_attached :call_in
  has_one_attached :decision_letter
  has_one_attached :submission_text
  has_one_attached :withdraw_document
  has_one_attached :sau_withdrawn_doc
  has_many_attached :final_report
  has_many_attached :assessment_docs
  has_many_attached :character_desc_docs

  belongs_to :public_authority
  belongs_to :user
  belongs_to :submitted_by, class_name: "User", optional: true

  has_one :post_report
  has_many :information_requests, -> { order("created_at desc") }
  has_many :audit_logs, -> { order("created_at desc") }, as: :log, dependent: :destroy

  serialize :completed_steps, Array
  serialize :sectors, Array
  serialize :purposes, Array
  serialize :ben_good_svr, Array
  serialize :location, Array
  serialize :subsidy_forms, Array

  scope :filter_by_status, ->(status) { where status: }
  scope :filter_by_user, ->(user_id) { where user_id: }
  scope :filter_by_pa, ->(pa_id) { where public_authority_id: pa_id }
  scope :submitted, -> { where.not(reference_number: nil) }
  scope :pa_requests, ->(id) { where("public_authority_id = ?", id) }
  scope :pa_ga_requests, ->(pa_ids) { joins(:public_authority).where public_authority_id: pa_ids }
  scope :sau_requests, -> { joins(:public_authority).where.not status: "Draft" }
  scope :open_sau_requests, -> { joins(:public_authority).where status: ["Accepted", "Pending withdrawal", "Submitted"] }
  scope :filter_by_internal_state, ->(internal_state) { where("internal_state LIKE ?", "%#{Request.sanitize_sql_like(internal_state)}%") }
  scope :submitted_by, ->(user_id) { where submitted_by_id: user_id }

  # TAX_OPTIONS = %w[upto_60 upto_500 upto_1000 upto_2000 upto_5000 upto_10000 upto_30000 over_30000].freeze

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

  SUBSIDY_FORM_OPTIONS = %w[dire equi gaur loan above below tax other].freeze
  TAX_OPTIONS = %w[upto_100 upto_300 upto_500 upto_750 upto_1500 upto_3000 upto_5000 upto_7500 upto_10000 upto_20000 upto_30000 over_30000].freeze
  STATUS = ["Accepted", "Completed", "Declined", "Draft", "Pending withdrawal", "Rejected", "Submitted", "Withdrawn"].freeze
  ACTIONS = ["Continue", "Info required", "View", "View report"].freeze
  MAX_WORDCOUNT = 500

  attr_accessor :continue_btn

  def select_tax_options
    [OpenStruct.new(name: "Select range", id: "")] +
      TAX_OPTIONS.map do |id|
        OpenStruct.new(id:, name: I18n.t(id&.to_sym, scope: [:tax_amount]))
      end
  end

  def field_too_long(field, size = MAX_WORDCOUNT)
    field.present? && field.strip.split(/\S+/).size > size
  end

  def permitted
    %w[].freeze
  end

  def new_internal_state(new_value, replacing = nil)
    new_internal_state = internal_state.to_s
    new_internal_state = new_internal_state.gsub(new_value, "")
    new_internal_state = new_internal_state.gsub(replacing, "") if replacing.present?
    new_internal_state << new_value
  end

  # allow pages that don't update object, such as information and confirmation pages
  def info_only?
    permitted.empty?
  end

  def ordered_assessment_docs
    assessment_docs.includes(:blob).references(:blob).order("active_storage_blobs.filename ASC")
  end

  def ordered_character_desc_docs
    character_desc_docs.includes(:blob).references(:blob).order("active_storage_blobs.filename ASC")
  end

  def self.next_reference_number
    max_submitted = Request.submitted.count
    sprintf("SAU%05d", max_submitted + 1)
  end

  def upload_step?
    false
  end

  CORE_FIELDS = %w[referral_type description is_nc third_party_email].freeze
  CALL_IN_FIELDS = %w[direction_date call_in_type].freeze
  PAR_FIELDS = %w[direction_date par_on_td par_assessed].freeze
  SUBSIDY_FIELDS = %w[subsidy_form is_emergency ben_id_type ben_id beneficiary ben_size legal policy confirm_date].freeze
  SCHEME_FIELDS = %w[scheme_name budget is_emergency legal policy confirm_date start_date].freeze
  # ASSESSMENT_FIELDS = %w[ee_assess_required assess_pa assess_pb assess_pc assess_pd assess_pe assess_pf assess_pg].freeze
  # EE_ASSESSMENT_FIELDS = %w[assess_ee_pa assess_ee_pb].freeze

  ASSESSMENT_FIELDS = %w[ee_assess_required is_c2_relevant is_p3_relevant].freeze
  EE_ASSESSMENT_FIELDS = %w[].freeze

  def determine_required_fields
    fields = CORE_FIELDS
    fields += CALL_IN_FIELDS if referral_type == "call"
    fields += PAR_FIELDS if referral_type == "par"
    fields += ASSESSMENT_FIELDS if referral_type != "par" || par_assessed != "n"
    fields += EE_ASSESSMENT_FIELDS if ee_assess_required == "y" && (referral_type != "par" || par_assessed != "n")

    fields += %w[c2_description] if is_c2_relevant == "y" && (referral_type != "par" || par_assessed != "n")
    fields += %w[p3_description] if is_p3_relevant == "y" && (referral_type != "par" || par_assessed != "n")
    fields += %w[nc_description] if is_nc == "no"
    fields += %w[par_td_ref_no] if referral_type == "par" && par_on_td == "y"
    fields += %w[par_reason] if referral_type == "par" && par_assessed == "n"
    fields += %w[character_desc] unless referral_type == "par" || (referral_type == "call" && call_in_type == "other")
    fields += %w[emergency_desc] if is_emergency == "y"

    # Ignore fields when a Post-award has been added to transparency database
    if referral_type != "par" || par_on_td == "n"
      fields += SCHEME_FIELDS if scheme_subsidy == "scheme"
      fields += %w[other_purpose] if purposes.present? && purposes.include?("other")
      if scheme_subsidy == "subsidy"
        fields += SUBSIDY_FIELDS
        fields += %w[other_form] if subsidy_form == "other"
        fields += %w[budget] if subsidy_form != "tax"
        fields += %w[tax_amt] if subsidy_form == "tax"
        fields += %w[tax_low tax_high] if subsidy_form == "tax" && tax_amt == "over_30000"
      elsif subsidy_forms.present? && subsidy_forms.include?("other")
        fields += %w[other_form]
      end
    end

    fields
  end

  def required_fields
    @required_fields ||= determine_required_fields
  end

  def field_required?(field_name)
    required_fields.include?(field_name.to_s)
  end

  def submitable?
    submitable = true
    submitable &= call_in.attached? if referral_type == "call" || referral_type == "par"

    # complex interaction rules

    if referral_type != "par" || par_on_td == "n"
      submitable &= ben_good_svr.count > 1
      submitable &= location.count > 1
      submitable &= sectors.count > 1
      submitable &= purposes.count > 1
      if scheme_subsidy == "scheme"
        submitable &= subsidy_forms.count > 1
      end
    end

    if referral_type != "par" || par_assessed != "n"
      submitable &= assessment_docs.attached?
    end

    required_fields.each do |f|
      submitable &= send(f).present?
    end

    submitable
  end
end
