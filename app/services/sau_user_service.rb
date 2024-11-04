class SauUserService
  URL_ENV = "AZURE_API".freeze

  def initialize; end

  def get_users
    @get_users ||= get_users_result
  end

  def get_users_result
    if ENV.key?(URL_ENV)
      call_api_get_users
    end
  end

  def get_group_users(group)
    @get_group_users ||= get_group_users_result(group)
  end

  def get_group_users_result(group)
    if ENV.key?(URL_ENV)
      call_api_get_group_users(group)
    end
  end

  def remove_user(group, id)
    if ENV.key?(URL_ENV)
      call_api_remove_user(group, id)
    end
  end

  def add_user(group, email_addr)
    if ENV.key?(URL_ENV)
      call_api_add_user(group, email_addr)
    end
  end

private

  def call_api_get_users
    body = {
      method: "SAUUser.GetAllUsers",
    }.to_json
    send_post(body)
  end

  def call_api_get_group_users(group)
    body = {
      method: "SAUUser.GetUsers",
      payload: {
        userGroup: group,
      },
    }.to_json

    send_post(body)
  end

  def call_api_remove_user(group, id)
    body = {
      method: "SAUUser.RemoveUser",
      payload: {
        userGroup: group,
        userId: id,
      },
    }.to_json

    send_post(body)
  end

  def call_api_add_user(group, email_addr)
    body = {
      method: "SAUUser.AddUser",
      payload: {
        userGroup: group,
        email: email_addr,
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
