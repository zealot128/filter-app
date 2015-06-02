require "download_url"
class Source < ActiveRecord::Base
  has_many :news_items, dependent: :destroy
  validates_presence_of :url, :name
  after_create :refresh
  after_create :download_thumb

  has_attached_file :logo, styles: {
    thumb: ["16x16", :png],
    small: ["50x50", :png]
  }
  do_not_validate_attachment_file_type :logo

  def self.[](search)
    where('url ilike ?', '%' + search + '%').first
  end

  def to_param
    "#{id}-#{name.to_url}"
  end

  def host
    uri = URI.parse(url)
    uri.path = "/"
    uri.fragment = nil
    uri.query = nil
    uri.to_s
  end

  def remote_url
    url
  end

  def age_in_weeks
    ((Time.now - created_at) / 1.week).ceil
  end

  def download_thumb
    doc = Nokogiri.parse(open(host, redirect: true))
    if rel = doc.at("link[rel=icon]") || rel = doc.at("link[rel='shortcut icon']") || rel = doc.at("link[rel='Shortcut icon']")
      path = URI.join(url, rel["href"]).to_s
    else
      path = URI.join(url, "/favicon.ico").to_s
    end
    self.update_attributes logo: download_url(path)
  rescue Exception => e
    Rails.logger.error "Logo download fehlgeschlagen fuer #{id} -> #{e.inspect}"
  end

  def self.cronjob
    Source.find_each do |t|
      begin
        t.refresh
      rescue Exception => e
        t.update_column :error, true
        $stderr.puts "Fehler bei #{t.url} (#{t.id}) #{e.inspect}"
      end
    end
  end

  def refresh
    raise "NotImplementedError"
  end

end
