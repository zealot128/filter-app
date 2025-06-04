class StaticPagesController < ApplicationController
  def categories
    @_include_app_js = true
    @news_items = NewsItem.home_page.limit(48)
  end

  def impressum
    @impressum = helpers.obfuscate_emails_in_html(Setting.get('impressum'))
  end

  def datenschutz
    @datenschutz = helpers.obfuscate_emails_in_html(Setting.get('datenschutz'))
  end

  def faq
  end

  def sources
  end
end
