class PostReport < ApplicationRecord
  belongs_to :request

  serialize :completed_steps, Array
  serialize :pa_names, Array
  serialize :special_cat_values, Array

  REL_OPTIONS = %w[rel not_rel].freeze
  YES_NO_OPTIONS = %w[y n].freeze
  SPECIAL_CAT_OPTIONS = %w[spei rest].freeze
  MAX_CHAR_COUNT = 10_000

  def permitted
    %w[].freeze
  end

  # allow pages that don't update object, such as information and confirmation pages
  def info_only?
    permitted.empty?
  end

  def pa_name_options
    @pa_name_options ||= ReportPaName.active_names.order(:pa_name).map(&:pa_name)
  end

  CORE_FIELDS = %w[pa_names referral_name confi_issues special_cats third_party_reps value other_issues].freeze
  PRINCIPLE_FIELDS = %w[pa_policy_evidence pa_market_fail pa_equity pe_policy pe_other_means pc_counterfactual pc_eco_behaviour pd_additionality pd_costs pb_proportion pf_subsidy_char pf_market_char pg_balance_uk pg_balance_intl].freeze
  EE_FIELDS = %w[ee_principles ee_issues].freeze
  EE_CHECK_FIELDS = %w[ee_required].freeze

  def determine_required_fields
    fields = CORE_FIELDS
    fields += PRINCIPLE_FIELDS
    fields += EE_CHECK_FIELDS if request.ee_assess_required != "y"
    fields += EE_FIELDS if request.ee_assess_required == "y" || ee_required == "y"

    PRINCIPLE_FIELDS.each do |f|
      fields += ["#{f}_text"] if send(f).present? && send(f) == "y"
    end
    fields += %w[confi_issues_text] if confi_issues == "y"
    fields += %w[third_party_reps_text] if third_party_reps == "y"
    fields += %w[reject_reason] if request.status == "Rejected"
    fields += %w[ee_issues_text] if (request.ee_assess_required == "y" || ee_required == "y") && ee_issues_text == "y"
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

    submitable &= pa_names.count > 1
    submitable &= special_cat_values.count > 1 if special_cats == "y"

    required_fields.each do |f|
      submitable &= send(f).present?
    end

    submitable
  end
end
