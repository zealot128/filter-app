class StaticPagesController < ApplicationController
  def categories
    @_include_app_js = true
    @news_items = NewsItem.home_page.limit(48)
  end

  def impressum
    @impressum = I18n.t("impressum.#{Setting.key}")
  end

  def datenschutz
    @datenschutz = I18n.t("datenschutz.#{Setting.key}")
  end

  def faq
  end

  def sources
  end
end
