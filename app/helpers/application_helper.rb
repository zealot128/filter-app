module ApplicationHelper
  def page_title
    [ @title, Configuration.site_name].reject(&:blank?).join(' | ')
  end
  def homepage(url)
    URI.parse(url).tap{|o| o.path = '/'; o.query =nil}.to_s
  end
end
