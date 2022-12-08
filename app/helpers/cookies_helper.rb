module CookiesHelper
  def confirm_cookies
    !cookie_settings["confirmed"] || cookie_settings["version"] != 1
  end

  def cookie_settings
    JSON.parse cookies.fetch("cookie_setting", '{"essential": true, "analytics": false, "confirmed": false, "version":1}')
  end

  def cookie_form
    @cookie_form ||= CookieForm.new(cookie_settings)
  end
end
