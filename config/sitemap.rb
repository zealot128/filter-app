# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://#{Setting.host}"
SitemapGenerator::Sitemap.sitemaps_path = 'system/'

SitemapGenerator::Sitemap.create do
  add "/", priority: 0.9, changefreq: "daily"
  add faq_path
  add '/quellen'

  Source.visible.each do |s|
    add source_path(s), priority: 0.4, changefreq: 'weekly'
  end
  Category.find_each do |c|
    add category_path(c)
  end
end
