require "fetcher"
class NewsItem < ActiveRecord::Base
  MAX_AGE ||= 14.days

  scope :current, -> { where("published_at > ?", MAX_AGE.ago) }
  scope :old, -> { where("published_at < ?", (MAX_AGE + 1.day).ago) }
  scope :home_page, -> { order("value desc").where("value is not null").current }
  scope :sorted, -> { order("value desc") }

  belongs_to :source
  has_and_belongs_to_many :categories
  has_many :incoming_links, class_name: "Linkage", foreign_key: "to_id"
  has_many :outgoing_links, class_name: "Linkage", foreign_key: "from_id", source: :from
  has_many :referenced_news, class_name: "NewsItem", through: :incoming_links, source: 'from'

  before_save :categorize
  before_save :filter_plaintext

  validates_uniqueness_of :guid, scope: [:source_id]

  include PgSearch
  pg_search_scope :search_full_text,
    :order_within_rank => "news_items.published_at DESC",
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
    NewsItem.current.each do |item|
      item.refresh
    end
  end

  # freshness max 120
  def to_data
    {
      facebook: fb_likes,
      twitter: retweets,
      linkedin: linkedin,
      xing: xing,
      gplus: gplus,
      freshness:  (published_at.to_i - MAX_AGE.ago.to_i) / 10000,
      bias: source.value,
      word_length: word_length,
      categories: category_ids,
      # parallel_news_count: source.news_items.where('published_at between ? and ?', 1.week.ago, 1.week.from_now).count,
      published_at: published_at.to_i,
      incoming_link_count: incoming_link_count || 0
    }
  end

  def categorize
    if plaintext
      self.categories = Category.all.select{|i|
        i.matches?(plaintext + ' ' + title)
      }
    end
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
    NewsItem::FullTextFetcher.new(self).run
  end

  def refresh
    if source.is_a? FeedSource
      NewsItem::LikeFetcher.fetch_for_news_item(self)
      rescore!
    end
  end

  def rescore!
    result = NewsItem::ScoringAlgorithm.new(to_data, max_age: MAX_AGE.ago).run
    self.absolute_score = result[:absolute_score]
    self.value = result[:relative_score]
    save
  end

  def to_partial_path
    "news_items/#{source.class.model_name.element}_item"
  end

end
