class UserService
  URL_ENV = "AZURE_API".freeze

  def initialize; end

  def invitation_result(user)
    @invitation_result ||= request_invitation(user)
  end

  def has_case_access_result(user_id, request_id)
    @has_case_access_result ||= has_case_access(user_id, request_id)
  end

  def pa_user_result(user_email, creator_name, creator_email, pa_name)
    @pa_user_result ||= pa_user_email(user_email, creator_name, creator_email, pa_name)
  end

  def remove_user_result(oid, role)
    @remove_user_result ||= remove_user(oid, role)
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

  def pa_user_email(user_email, creator_name, creator_email, pa_name)
    if ENV.key?(URL_ENV)
      call_pa_user_email(user_email, creator_name, creator_email, pa_name)
    end
  end

  def remove_user(oid, role)
    if ENV.key?(URL_ENV)
      call_remove_user(oid, role)
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
    send_post(body)
  end

  def call_has_case_access(user_id, request_id)
    body = {
      method: "User.HasCaseAccess",
      payload: {
        userId: user_id,
        requestId: request_id,
      },
    }.to_json
    send_post(body)
  end

  def call_pa_user_email(user_email, creator_name, creator_email, pa_name)
    body = {
      method: "User.PACreatedUser",
      payload: {
        userCreated: user_email,
        creatorName: creator_name,
        creatorEmail: creator_email,
        pa_name:,
      },
    }.to_json
    send_post(body)
  end

  def call_remove_user(oid, role)
    body = {
      method: "User.Remove",
      payload: {
        userId: oid,
        role:,
      },
    }.to_json
    send_post(body)
  end

  def send_post(body)
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
