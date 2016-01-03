module ApplicationHelper
  def page_title
    [ @title, Configuration.site_name].reject(&:blank?).join(' | ')
  end
end
