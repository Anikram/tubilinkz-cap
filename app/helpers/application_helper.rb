module ApplicationHelper
  def short_url(link)
    host = link.domain || Rails.application.routes.default_url_options[:host]
    shortlink_url(host: host, short_url: link.name)
  end
end
