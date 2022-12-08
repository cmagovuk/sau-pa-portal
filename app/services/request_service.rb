class RequestService
  attr_reader :sau_email

  URL_ENV = "AZURE_API".freeze

  def initialize; end

  def submit_request(request)
    @submit_request ||= request_submission(request)
  end

  def request_submission(request)
    if ENV.key?(URL_ENV)
      call_api_request_submission(request)
    end
  end

  def submit_response(information_request)
    @submit_response ||= call_api_info_response(information_request)
  end

private

  def call_api_info_response(information_request)
    response_doc = []
    if information_request.response_doc.attached?
      response_doc.push({ key: information_request.response_doc.key, filename: information_request.response_doc.filename })
    end

    body = {
      method: "RequestReport.InformationResponse",
      payload: {
        uniqueId: information_request.request.id,
        documents: response_doc,
      },
    }.to_json

    url = ENV.fetch(URL_ENV)

    conn = Faraday.new do |f|
      f.response :json # decode response body as JSON
    end

    response = conn.post(url, body, "Content-Type" => "application/json")
    if response.body["success"]
      @sau_email = response.body["data"]
      true
    else
      Rails.logger.warn "API failed"
      Rails.logger.warn response.body["error"] if response.body["error"].present?
      false
    end
  end

  def call_api_request_submission(request)
    assessment = []
    call_in_doc = []
    par_doc = []
    submission_doc = []
    description_docs = []

    if request.assessment_docs.attached?
      request.assessment_docs.each do |single|
        assessment.push({ key: single.key, filename: single.filename })
      end
    end

    if request.call_in.attached? && request.referral_type == "call"
      call_in_doc.push({ key: request.call_in.key, filename: request.call_in.filename })
    end

    if request.submission_text.attached?
      submission_doc.push({ key: request.submission_text.key, filename: request.submission_text.filename })
    end

    if request.call_in.attached? && request.referral_type == "par"
      par_doc.push({ key: request.call_in.key, filename: request.call_in.filename })
    end

    if request.character_desc_docs.attached?
      request.character_desc_docs.each do |single|
        description_docs.push({ key: single.key, filename: single.filename })
      end
    end

    body = {
      method: "RequestReport.Submit",
      payload: {
        reference: request.reference_number,
        uniqueId: request.id,
        documents: {
          assessment_docs: assessment,
          call_in_docs: call_in_doc,
          par_docs: par_doc,
          submission_docs: submission_doc,
          description_docs: description_docs,
        },
        request: request,
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
