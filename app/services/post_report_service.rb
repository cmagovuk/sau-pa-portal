class PostReportService
  attr_reader :sau_email

  URL_ENV = "AZURE_API".freeze

  def initialize; end

  def submit_post_report(request)
    @submit_post_report ||= call_api_post_report_submission(request)
  end

private

  def translate_terms(terms, translation_scope)
    compact_terms = terms.select(&:present?)
    compact_terms.map { |t| I18n.t "#{translation_scope}.#{t}" }
  end

  def call_api_post_report_submission(request)
    body = {
      method: "PostReport.Submit",
      payload: {
        reference: request.reference_number,
        scheme_subsidy: request.scheme_subsidy.present? ? I18n.t(request.scheme_subsidy&.to_sym, scope: [:scheme_subsidy]) : null,
        referral_type: request.referral_type.present? ? I18n.t(request.referral_type&.to_sym, scope: %i[referral_type short]) : null,
        is_c2_relevant: request.is_c2_relevant,
        is_p3_relevant: request.is_p3_relevant,
        ee_assess_required: request.ee_assess_required,
        subsidy_forms: translate_terms((request.scheme_subsidy == "scheme" ? request.subsidy_forms : [request.subsidy_form]), "subsidy_form_options"),
        sectors: translate_terms(request.sectors, "helpers.label.request.sectors_options"),
        purposes: translate_terms(request.purposes, "helpers.label.request.purposes_options"),
        locations: translate_terms(request.location, "helpers.label.request.location_options"),
        beneficiary: request.beneficiary.present? ? request.beneficiary[0, 255] : nil,
        ben_size: (request.scheme_subsidy == "subsidy" && request.ben_size.present? ? t(request.ben_size&.to_sym, scope: "helpers.label.request.ben_size_options") : nil),
        ben_good_svr: translate_terms(request.ben_good_svr, "helpers.label.request.ben_good_svr_options"),
        start_date: request.start_date,
        end_date: request.end_date,
        confirm_date: request.confirm_date,
        submitted_date: request.submitted_date,
        completed_date: request.completed_date,
        post_report: request.post_report,
      },
    }.to_json

    url = ENV.fetch(URL_ENV)

    conn = Faraday.new do |f|
      f.response :json # decode response body as JSON
    end

    response = conn.post(url, body, "Content-Type" => "application/json")
    if response.body["success"]
      true
    else
      Rails.logger.warn "API failed"
      Rails.logger.warn response.body["error"] if response.body["error"].present?
      false
    end
  end
end
