require "download_url"
class Source < ActiveRecord::Base
  has_many :news_items, dependent: :destroy
  validates_presence_of :url, :name
  after_create :refresh
  after_create :download_thumb

  has_attached_file :logo, styles: {
    thumb: ["16x16", :png]
  }

  def self.[](search)
    where('url ilike ?', '%' + search + '%').first
  end

  def host
    uri = URI.parse(url)
    uri.path = "/"
    uri.fragment = nil
    uri.query = nil
    uri.to_s
  end

  def age_in_weeks
    ((Time.now - created_at) / 1.week).ceil
  end

  def download_thumb
    doc = Nokogiri.parse(open(host))
    if rel = doc.at("link[rel=icon]") || rel = doc.at("link[rel='shortcut icon']") || rel = doc.at("link[rel='Shortcut icon']")
      path = URI.join(url, rel["href"]).to_s
    else
      path = URI.join(url, "/favicon.ico").to_s
    end
    self.update_attributes logo: download_url(path)
  end

  def self.cronjob
    Source.find_each do |t|
      begin
        t.refresh
      rescue Exception
        puts "Fehler bei #{t.url} (#{t.id})"
      end
    end
    NewsItem.cronjob
  end

  def refresh
    raise "NotImplementedError"
  end
end
