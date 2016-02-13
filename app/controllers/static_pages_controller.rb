class StaticPagesController < ApplicationController

  def categories
    @_include_app_js = true
    @news_items = NewsItem.home_page.limit(48)
  end

  def about
    @impressum = I18n.t("impressum.#{::Configuration.key}")
  end

  def sources
  end
end
