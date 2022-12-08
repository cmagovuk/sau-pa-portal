class UserService
  URL_ENV = "AZURE_API".freeze

  def initialize; end

  def invitation_result(user)
    @invitation_result ||= request_invitation(user)
  end

  def has_case_access_result(user_id, request_id)
    @has_case_access_result ||= has_case_access(user_id, request_id)
  end

  def request_invitation(user)
    if ENV.key?(URL_ENV)
      call_api_invite(user)
    end
  end

  def has_case_access(user_id, request_id)
    if ENV.key?(URL_ENV)
      call_has_case_access(user_id, request_id)
    end
  end

private

  def call_api_invite(user)
    body = {
      method: "User.InviteToRole",
      payload: {
        email: user.email,
        role: user.role,
      },
    }.to_json
    url = ENV.fetch(URL_ENV)

    conn = Faraday.new do |f|
      f.response :json # decode response body as JSON
    end

    response = conn.post(url, body, "Content-Type" => "application/json")
    if response.body["success"]
      response.body["data"]
    else
      Rails.logger.warn "API failed"
      Rails.logger.warn response.body["error"] if response.body["error"].present?
      nil
    end
  end

  def call_has_case_access(user_id, request_id)
    body = {
      method: "User.HasCaseAccess",
      payload: {
        userId: user_id,
        requestId: request_id,
      },
    }.to_json
    url = ENV.fetch(URL_ENV)

    conn = Faraday.new do |f|
      f.response :json # decode response body as JSON
    end

    response = conn.post(url, body, "Content-Type" => "application/json")
    if response.body["success"]
      response.body["data"]
    else
      Rails.logger.warn "API failed"
      Rails.logger.warn response.body["error"] if response.body["error"].present?
      nil
    end
  end
end
