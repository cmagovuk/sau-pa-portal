module ApplicationHelper
  def service_name
    t("service.name")
  end

  def analytics_tracking_id
    Rails.application.config.x.analytics_tracking_id
  end

  def transparency_link
    Rails.application.config.x.transparency_link
  end

  def title(page_title)
    content_for :page_title, [page_title.presence, service_name, "GOV.UK"].compact.join(" - ")
  end

  def path_only(url)
    return nil if url.nil?

    URI.parse(url).tap { |uri|
      uri.host = nil
      uri.port = nil
      uri.scheme = nil
    }.to_s
  end
end
