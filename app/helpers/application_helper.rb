module ApplicationHelper
  def page_title
    title = if @title
        @title
      elsif content_for?(:title)
        yield(:title)
      else
        nil
      end

    [ title, Configuration.site_name].reject(&:blank?).join(' | ')
  end
end
