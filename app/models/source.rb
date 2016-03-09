require "download_url"
class Source < ActiveRecord::Base
  has_many :news_items, dependent: :destroy
  validates_presence_of :url, :name

  belongs_to :default_category, class_name: 'Category'
  after_create :download_thumb, if: -> { !Rails.env.test? }
  scope :visible, -> { where(deactivated: false) }

  has_attached_file :logo, styles: {
    thumb: ["16x16", :png],
    small: ["50x50", :png]
  }, processors: [:thumbnail, :paperclip_optimizer]

  has_attached_file :lsr_confirmation

  validates_attachment :logo,
    content_type: { content_type: ["image/jpeg", "image/gif", "image/png", "image/x-icon", "image/vnd.microsoft.icon"] }
  # do_not_validate_attachment_file_type :logo

  def self.[](search)
    where('url ilike ?', '%' + search + '%').first
  end

  def to_param
    "#{id}-#{name.to_url}"
  end

  def homepage_url
    URI.parse(url).tap{|o| o.path = '/'; o.query =nil}.to_s
  end

  def host
    uri = URI.parse(url)
    uri.path = "/"
    uri.fragment = nil
    uri.query = nil
    uri.to_s
  end

  def host_name
    URI.parse(host).host
  end

  def remote_url
    url
  end

  def source_name
    I18n.t("source.class.#{type}")
  end

  def age_in_weeks
    ((Time.now - created_at) / 1.week).ceil
  end

  def download_thumb
    doc = Nokogiri.parse(open(host, redirect: true, allow_redirections: :all))
    if rel = doc.at("link[rel=icon]") || rel = doc.at("link[rel='shortcut icon']") || rel = doc.at("link[rel='Shortcut icon']")
      path = URI.join(url, rel["href"]).to_s
    else
      path = URI.join(url, "/favicon.ico").to_s
    end
    file = download_url(path)

    if !update_attributes logo: file
      # imagemagick can't find file-type -> try renaming to ico
      file.rewind
      tf = Tempfile.new(["thumb", ".ico"])
      tf.binmode
      tf.write file.read
      if update_attributes logo: tf
        logo.reprocess!
      end
    end
  rescue Exception => e
    Rails.logger.error "Logo download fehlgeschlagen fuer #{id} -> #{e.inspect}"
  end

  def self.cronjob
    Rails.logger.info "Starting Source.cronjob"

    Source.visible.find_each do |t|
      begin
        t.refresh
        t.update_column :error, false
      rescue Exception => e
        t.update_column :error, true
        Rails.logger.error "Fehler bei #{t.url} (#{t.id}) #{e.inspect}"
      end
    end
    Rails.logger.info "Finished Source.cronjob"
  end

  def average_word_length
    (s = news_items.visible.order('created_at desc').limit(5).average(:word_length)) && s.round
  end

  def should_fetch_stats?(ni)
    false
  end

  def refresh
    fail "NotImplementedError"
  end
end
