# == Schema Information
#
# Table name: sources
#
#  id                            :integer          not null, primary key
#  type                          :string(255)
#  url                           :string(255)
#  name                          :string(255)
#  value                         :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  logo_file_name                :string(255)
#  logo_content_type             :string(255)
#  logo_file_size                :integer
#  logo_updated_at               :datetime
#  full_text_selector            :string(255)
#  error                         :boolean
#  multiplicator                 :float            default(1.0)
#  lsr_active                    :boolean          default(FALSE)
#  deactivated                   :boolean          default(FALSE)
#  default_category_id           :integer
#  lsr_confirmation_file_name    :string
#  lsr_confirmation_content_type :string
#  lsr_confirmation_file_size    :integer
#  lsr_confirmation_updated_at   :datetime
#  twitter_account               :string
#  language                      :string
#  comment                       :text
#  filter_rules                  :text
#  statistics                    :json
#  error_message                 :text
#

require "download_url"
class Source < ApplicationRecord
  has_many :news_items, dependent: :destroy
  validates :url, :name, presence: true

  SOURCE_TYPES = ['FeedSource', 'TwitterSource', 'PodcastSource', 'RedditSource', 'FacebookSource', 'YoutubeSource'].freeze

  belongs_to :default_category, class_name: 'Category'
  after_create_commit if: -> { !Rails.env.test? } do
    Source::DownloadThumbWorker.perform_async(id)
  end
  scope :visible, -> { where(deactivated: false) }
  scope :antiquated, -> {
    where('(select max(published_at) from news_items where news_items.source_id = sources.id) < ?', 12.months.ago).
      where.not(deactivated: true).
      where.not(error: true)
  }
  scope :with_error, -> { visible.where(error: true) }

  has_attached_file :logo, styles: {
    thumb: ["16x16", :png],
    small: ["50x50", :png]
  }, processors: [:thumbnail, :paperclip_optimizer]

  has_attached_file :lsr_confirmation

  validates_attachment :logo,
    content_type: { content_type: ["image/jpeg", "image/gif", "image/png", "image/x-icon", "image/vnd.microsoft.icon"] }
  # do_not_validate_attachment_file_type :logo

  def self.[](search)
    find_by('url ilike ?', '%' + search + '%')
  end

  def to_param
    "#{id}-#{name.to_url}"
  end

  def homepage_url
    URI.parse(url).tap { |o|
      o.path = '/'
      o.query = nil
    }.to_s
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
    ((Time.zone.now - created_at) / 1.week).ceil
  end

  def download_thumb
    doc = Nokogiri.parse(open(host, redirect: true, allow_redirections: :all))
    path = if (rel = doc.at("link[rel=icon]")) || (rel = doc.at("link[rel='shortcut icon']")) || (rel = doc.at("link[rel='Shortcut icon']"))
             URI.join(url, rel["href"]).to_s
           else
             URI.join(url, "/favicon.ico").to_s
           end
    file = download_url(path)

    unless update logo: file
      # imagemagick can't find file-type -> try renaming to ico
      file.rewind
      tf = Tempfile.new(["thumb", ".ico"])
      tf.binmode
      tf.write file.read
      if update logo: tf
        logo.reprocess!
      end
    end
  rescue StandardError => e
    Rails.logger.error "Logo download fehlgeschlagen fuer #{id} -> #{e.inspect}"
  end

  def self.cronjob
    Source.visible.find_each do |s|
      Source::FetchWorker.perform_async(s.id)
    end
  end

  def wrapped_refresh!
    begin
      refresh
      update_column :error, false
    rescue StandardError => e
      update error: true, error_message: e.inspect
    end
    update_statistics!
  end

  def average_word_length
    (s = news_items.visible.order('created_at desc').limit(5).average(:word_length)) && s.round
  end

  def should_fetch_stats?(ni)
    false
  end

  def refresh
    raise "NotImplementedError"
  end

  def update_statistics!
    update statistics: {
      top_categories: news_items.
        joins(:categories).
        group('categories.name').
        order('count_all desc').limit(3).count.map { |k, c| { name: k, count: c } },
      total_news_count: news_items.count,
      current_news_count: news_items.current.count,
      current_top_score: (news_items.current.maximum(:absolute_score) || 0).round,
      current_impression_count:  news_items.current.sum(:impression_count)
    }
  end
end
