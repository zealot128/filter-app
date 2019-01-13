# == Schema Information
#
# Table name: news_items
#
#  id                          :integer          not null, primary key
#  title                       :string(255)
#  teaser                      :text
#  url                         :string(255)
#  source_id                   :integer
#  published_at                :datetime
#  value                       :integer
#  fb_likes                    :integer
#  retweets                    :integer
#  guid                        :string(255)
#  linkedin                    :integer
#  xing                        :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  gplus                       :integer
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
#

require "fetcher"

# rubocop:disable Style/GuardClause
class NewsItem < ApplicationRecord
  # half life of items is 12.5 hours; all items within the same batch get the same base time score
  HALF_LIFE = 45_000

  is_impressionable counter_cache: true, column_name: :impression_count, unique: :session_hash

  def self.max_age
    Setting.max_age.to_i.days
  end

  scope :visible, -> {
    where('blacklisted != ?', true).
      where('news_items.absolute_score is not null and news_items.absolute_score > 0').
      where('absolute_score_per_halflife is not null').
      where(source_id: Source.visible.select('id'))
  }
  scope :show_page, -> {
    where('blacklisted != ?', true).
      order('published_at desc').
      where('absolute_score is not null and absolute_score > 0')
  }
  scope :newspaper, -> { where('blacklisted != ?', true).where('absolute_score is not null and absolute_score >= 0').order('absolute_score desc') }
  scope :current, -> { visible.recent }
  scope :old, -> { where("published_at < ?", (max_age + 1.day).ago) }
  scope :home_page, -> { where('news_items.value > 0').visible.order("news_items.value desc").where("news_items.value is not null").current }
  scope :sorted, -> { visible.order("news_items.absolute_score desc") }
  scope :recent, -> { where("published_at > ?", max_age.ago) }
  scope :top_of_day, ->(date) { newspaper.where('date(published_at) = ?', date.to_date) }

  scope :top_percent_per_day, ->(min_date, percentile, min_news_per_day) {
    NewsItem.where(
      %{ news_items.id in (
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
      }
    )
  }

  scope :top_percent_per_week, ->(min_date, percentile, min_news_per_day) {
    NewsItem.where(
      %{ news_items.id in (
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
      }
    )
  }
  scope :top_percent_per_month, ->(min_date, percentile, min_news_per_day) {
    NewsItem.where(
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
      where('news_item_id is null').
      group('news_items.id')
  }

  belongs_to :source
  has_and_belongs_to_many :categories
  has_many :incoming_links, class_name: "Linkage", foreign_key: "to_id"
  has_many :outgoing_links, class_name: "Linkage", foreign_key: "from_id", source: :from
  has_many :referenced_news, -> { where('different = ?', true) }, class_name: "NewsItem", through: :incoming_links, source: 'from'
  has_many :referencing_news, -> { where('different = ?', true) }, class_name: "NewsItem", through: :outgoing_links, source: 'to'

  # before_save :categorize
  # before_save :filter_plaintext
  # before_save :blacklist

  validates :guid, uniqueness: { scope: [:source_id] }

  NEWSLETTER_SIZE = [140, 70].freeze
  has_attached_file :image,
    styles: {
      original: ["250x200>", :jpg],
      newsletter: [NEWSLETTER_SIZE.join('x') + "^", :jpg]
    },
    processors: [:thumbnail, :paperclip_optimizer],
    convert_options: {
      newsletter: "-flatten -colorspace RGB -size #{NEWSLETTER_SIZE.join('x')} xc:white +swap -gravity center -composite"
    }
  do_not_validate_attachment_file_type :image

  include PgSearch
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

  def self.cronjob
    Rails.logger.info "Starting NewsItem refresh cronjob"
    # delete all news items that are not attached to a source yet, rare race condition when dependent: destroy did not work
    NewsItem.where.not(source_id: Source.select('id')).delete_all
    priority = NewsItem.recent.where(value: nil)
    priority.each do |news_item|
      NewsItem::RefreshLikesWorker.perform_async(news_item.id)
    end
    NewsItem.recent.shuffle.each do |ni|
      next if priority.include?(ni)

      NewsItem::RefreshLikesWorker.perform_async(ni.id)
    end
    Rails.logger.info "Finished NewsItem refresh cronjob"
  end

  # freshness max 120
  def to_data
    {
      facebook: fb_likes,
      twitter: retweets,
      linkedin: linkedin,
      xing: xing,
      gplus: gplus,
      youtube_views: youtube_views,
      youtube_likes: youtube_likes,
      reddit: reddit || 0,
      freshness: (published_at.to_i - self.class.max_age.ago.to_i) / 10_000,
      bias: source.value,
      impression_count: impression_count,
      multiplicator: source.multiplicator,
      word_length: word_length,
      categories: category_ids,
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

  def get_full_text
    if full_text.blank? || updated_at < 1.day.ago
      NewsItem::FullTextFetcher.new(self).run
    end
  end

  def refresh
    if source && source.should_fetch_stats?(self)
      NewsItem::LikeFetcher.fetch_for_news_item(self)
    end
    rescore!
  end

  def rescore!
    result = NewsItem::ScoringAlgorithm.new(to_data, max_age: self.class.max_age.ago).run
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

  def as_json(options)
    super(methods: :image_url_full)
  end

  def image_url_full
    "https://#{Setting.host}#{image.url}"
  end

  def self.cleanup
    NewsItem.where('published_at < ?', 6.months.ago).where.not(image_file_name: nil).find_each { |i|
      i.image = nil
      i.save validate: false
    }
  end
end
