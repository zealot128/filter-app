# == Schema Information
#
# Table name: news_items
#
#  id                          :integer          not null, primary key
#  title                       :string
#  teaser                      :text
#  url                         :string(2048)
#  source_id                   :integer
#  published_at                :datetime
#  value                       :integer
#  fb_likes                    :integer
#  retweets                    :integer
#  guid                        :string(255)
#  xing                        :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  full_text                   :text
#  word_length                 :integer
#  plaintext                   :text
#  search_vector               :tsvector
#  incoming_link_count         :integer
#  absolute_score              :float
#  blacklisted                 :boolean          default(FALSE)
#  reddit                      :integer
#  image_file_name             :string
#  image_content_type          :string
#  image_file_size             :integer
#  image_updated_at            :datetime
#  impression_count            :integer          default(0)
#  tweet_id                    :string
#  absolute_score_per_halflife :integer
#  youtube_likes               :integer          default(0)
#  youtube_views               :integer          default(0)
#  category_order              :integer          is an Array
#  dupe_of_id                  :integer
#  trend_analyzed              :boolean          default(FALSE)
#  paywall                     :boolean          default(FALSE)
#  media_url                   :string
#  embeddable                  :boolean          default(FALSE)
#  like                        :integer          default(0)
#
# Indexes
#
#  index_news_items_on_absolute_score                   (absolute_score)
#  index_news_items_on_absolute_score_and_published_at  (absolute_score,published_at)
#  index_news_items_on_dupe_of_id                       (dupe_of_id)
#  index_news_items_on_guid                             (guid)
#  index_news_items_on_published_at                     (published_at)
#  index_news_items_on_search_vector                    (search_vector) USING gin
#  index_news_items_on_source_id                        (source_id)
#  index_news_items_on_value                            (value)
#

require "fetcher"
class NewsItem < ApplicationRecord
  auto_strip_attributes :url, :title, squish: true, convert_non_breaking_spaces: true
  # half life of items is 12.5 hours; all items within the same batch get the same base time score
  HALF_LIFE = 45_000

  def self.max_age
    Setting.max_age.to_i.days
  end

  scope :visible, -> {
    where.not(blacklisted: true).
      where('news_items.absolute_score is not null and news_items.absolute_score > 0').
      where.not(absolute_score_per_halflife: nil).
      where(source_id: Source.visible.select('id'))
  }
  scope :show_page, -> {
    where.not(blacklisted: true).
      order('published_at desc').
      where('absolute_score is not null and absolute_score > 0')
  }
  scope :newspaper, -> { where.not(blacklisted: true).where('absolute_score is not null and absolute_score >= 0').order('absolute_score desc') }
  scope :current, -> { visible.recent }
  scope :old, -> { where(published_at: ...(max_age + 1.day).ago) }
  scope :home_page, -> { where('news_items.value > 0').visible.order("news_items.value desc").where.not(news_items: { value: nil }).current }
  scope :sorted, -> { visible.order("news_items.absolute_score desc") }
  scope :recent, -> { where("published_at > ?", max_age.ago) }
  scope :after, ->(max_months) { where("published_at > ?", max_months) }
  scope :top_of_day, ->(date) { newspaper.where('date(published_at) = ?', date.to_date) }

  scope :top_percent_per_day, ->(min_date, percentile, min_news_per_day) {
    where(<<~SQL.squish)
       news_items.id in (
          SELECT id from (
            SELECT count(*) over(PARTITION BY published_at::date ) AS total_count,
            ROW_NUMBER() OVER (PARTITION BY published_at::date ORDER BY absolute_score DESC) as rank,
            published_at::date as date,
            id
            FROM news_items
            WHERE published_at > '#{min_date.to_date}'
          ) sub
          WHERE rank < GREATEST(total_count * #{percentile.to_f}, #{min_news_per_day.to_i})
          ORDER BY date DESC, rank DESC
      )
    SQL
  }

  scope :top_percent_per_week, ->(min_date, percentile, min_news_per_day) {
    where(<<~SQL.squish)
       news_items.id in (
          SELECT id from (
            SELECT count(*) over(PARTITION BY to_char(published_at, 'IW/IYYY') ) AS total_count,
            ROW_NUMBER() OVER (PARTITION BY to_char(published_at, 'IW/IYYY') ORDER BY absolute_score DESC) as rank,
            published_at::date as date,
            id
            FROM news_items
            WHERE published_at > '#{min_date.to_date}'
          ) sub
          WHERE rank < GREATEST(total_count * #{percentile.to_f}, #{min_news_per_day.to_i})
          ORDER BY date DESC, rank DESC
      )
    SQL
  }
  scope :top_percent_per_month, ->(min_date, percentile, min_news_per_day) {
    where(
      %{ news_items.id in (
          SELECT id from (
            SELECT count(*) over(PARTITION BY to_char(published_at, 'MM/YYYY') ) AS total_count,
            ROW_NUMBER() OVER (PARTITION BY to_char(published_at, 'MM/YYYY') ORDER BY absolute_score DESC) as rank,
            published_at::date as date,
            id
            FROM news_items
            WHERE published_at > '#{min_date.to_date}'
          ) sub
          WHERE rank < GREATEST(total_count * #{percentile.to_f}, #{min_news_per_day.to_i})
          ORDER BY date DESC, rank DESC
      )
      }
    )
  }

  scope :uncategorized, -> {
    joins('LEFT JOIN "categories_news_items" ON "categories_news_items"."news_item_id" = "news_items"."id"').
      where(news_item_id: nil).
      group('news_items.id')
  }
  scope :without_dupes, -> {
    where(dupe_of_id: nil)
  }

  belongs_to :source
  has_and_belongs_to_many :categories
  has_many :incoming_links, class_name: "Linkage", foreign_key: "to_id", inverse_of: :to
  has_many :outgoing_links, class_name: "Linkage", foreign_key: "from_id", inverse_of: :from
  has_many :referenced_news, -> { where(different: true) }, class_name: "NewsItem", through: :incoming_links, source: 'from'
  has_many :referencing_news, -> { where(different: true) }, class_name: "NewsItem", through: :outgoing_links, source: 'to'
  has_many :trend_usages, class_name: "Trends::Usage", dependent: :destroy
  belongs_to :dupe_of, class_name: "NewsItem", optional: true, inverse_of: :dupes
  has_many :dupes, class_name: "NewsItem", inverse_of: :dupe_of

  before_save do
    if title && title.length > 255
      self.title = title[0..255]
    end
    if url && url.length > 2048
      self.url = url[0..2048]
    end
  end
  # before_save :categorize
  # before_save :filter_plaintext
  # before_save :blacklist

  validates :guid, uniqueness: { scope: [:source_id] }

  NEWSLETTER_SIZE = [140, 70].freeze
  has_attached_file :image,
    styles: {
      original: ["700x400>", :jpg],
      newsletter: ["#{NEWSLETTER_SIZE.join('x')}^", :jpg]
    },
    processors: [:thumbnail],
    convert_options: {
      newsletter: "-flatten -colorspace RGB -size #{NEWSLETTER_SIZE.join('x')} xc:white +swap -gravity center -composite"
    }
  do_not_validate_attachment_file_type :image

  include PgSearch::Model
  pg_search_scope :search_full_text,
    order_within_rank: "news_items.published_at DESC",
    against: :search_vector,
    using: {
      tsearch: {
        dictionary: 'german',
        any_word: true,
        prefix: true,
        tsvector_column: 'search_vector'
      }
    }

  def preferred_teaser_image
    if image.present?
      image.url
    else
      c = categories.first
      if c.logo.attached?
        c.logo.variant(resize: '130x130')
      end
    end
  end

  after_commit do
    NewsItem::AnalyseTrendJob.perform_later(id) unless trend_analyzed
  end

  def self.cronjob
    Rails.logger.info "Starting NewsItem refresh cronjob"
    # delete all news items that are not attached to a source yet, rare race condition when dependent: destroy did not work
    NewsItem.where.not(source_id: Source.select('id')).delete_all

    # TODO: Solid Queue?
    # return if Sidekiq::Queue.new('low').count > 200

    max = 150
    priority = NewsItem.recent.where(value: nil).limit(100).to_a
    priority.each_with_index do |news_item, i|
      NewsItem::RefreshLikesJob.set(wait: (i * 2).seconds).perform_later(news_item.id)
      max -= 1
    end
    NewsItem.recent.order('random()').limit(max).each_with_index do |ni, i|
      next if priority.include?(ni)

      wait = 15.minutes + (i * 2).seconds
      NewsItem::RefreshLikesJob.set(wait:).perform_later(ni.id)
    end
    Rails.logger.info "Finished NewsItem refresh cronjob"
  end

  # freshness max 120
  def to_data
    {
      facebook: fb_likes,
      twitter: retweets,
      gplus: 0,
      linkedin: 0,
      xing:,
      youtube_views:,
      youtube_likes:,
      reddit: reddit || 0,
      freshness: (published_at.to_i - self.class.max_age.ago.to_i) / 10_000,
      bias: source.value,
      impression_count:,
      multiplicator: source.multiplicator,
      word_length:,
      title_length: title.to_s.length,
      categories: category_ids,
      paywall:,
      # parallel_news_count: source.news_items.where('published_at between ? and ?', 1.week.ago, 1.week.from_now).count,
      published_at: published_at.to_i,
      incoming_link_count: incoming_link_count || 0
    }
  end

  def categorize
    Categorizer.run(self) if plaintext
  end

  def filter_plaintext
    self.plaintext = ActionController::Base.helpers.strip_tags(full_text || teaser || title || "")
    self.word_length = words.length
    self.incoming_link_count = referenced_news.count
  end

  def words
    plaintext.split(/[^\p{Word}]+/)
  end

  def get_full_text(force: false)
    if full_text.blank? || updated_at < 7.days.ago || force
      NewsItem::FullTextFetcher.new(self).run
    end
    save if force
  rescue Net::HTTP::Persistent::Error
  end

  def refresh
    rescore!
  end

  def rescore!
    result = NewsItem::ScoringAlgorithm.new(to_data, max_age: self.class.max_age.ago).run
    self.impression_count = Ahoy::Event.where(name: 'news_item').where("(properties->>'id')::int = ?", id).count
    self.absolute_score = result[:absolute_score]
    self.value = result[:relative_score]

    self.absolute_score_per_halflife = NewsItem::ScoringAlgorithm.hot_score(absolute_score, published_at, HALF_LIFE)
    save
  end

  def to_partial_path
    "news_items/#{source.class.model_name.element}_item"
  end

  def social_url
    if source.is_a?(RedditSource)
      source.url + "/comments/#{guid}/"
    end
  end

  def blacklist
    bl = ['Morgenimpuls', 'commun.it', '(insight by', 'Partner im Profil:', 'Partner kurz vorgestellt', 'Partner im Fokus', 'Partner im Blickpunkt',
          'Förderer kurz vorgestellt', 'Förderer im Fokus', 'Förderer im Blickpunkt', 'Community-Partner', 'Community-Förderer']
    if title and bl.any? { |t| title.include?(t) }
      self.blacklisted = true
    end
  end

  def as_json(options = {})
    super(options.merge(methods: :image_url_full)).merge(gplus: 0, linkedin: 0)
  end

  def image_url_full
    "https://#{Setting.host}#{image.url}"
  end

  def self.cleanup
    NewsItem.where(published_at: ...6.months.ago).where.not(image_file_name: nil).find_each { |i|
      i.image = nil
      i.save validate: false
    }
  end
end
