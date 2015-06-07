require "fetcher"
class NewsItem < ActiveRecord::Base
  MAX_AGE ||= 14.days
  has_and_belongs_to_many :categories
  belongs_to :source
  validates_uniqueness_of :guid, scope: [:source_id]

  scope :current, -> { where("published_at > ?", MAX_AGE.ago) }
  scope :old, -> { where("published_at < ?", (MAX_AGE + 1.day).ago) }
  scope :home_page, -> { order("value desc").where("value is not null").current }
  scope :sorted, -> { order("value desc") }

  has_many :incoming_links, class_name: "Linkage", foreign_key: "to_id"
  has_many :outgoing_links, class_name: "Linkage", foreign_key: "from_id", source: :from
  has_many :referenced_news, class_name: "NewsItem", through: :incoming_links, source: 'from'

  include FetcherConcern
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
      words: word_length,
      categories: category_ids
    }
  end

  before_save :categorize
  def categorize
    if plaintext
      self.categories = Category.all.select{|i|
        i.matches?(plaintext + ' ' + title)
      }
    end
  end

  before_save do
    self.plaintext = ActionController::Base.helpers.strip_tags(full_text || teaser || title || "")
    self.word_length = words.length
    self.incoming_link_count = referenced_news.count
  end

  def words
    plaintext.split(/[^\p{Word}]+/)
  end

  def get_full_text
    FullTextFetcher.new(self).run
  end

  def refresh
    if source.is_a? FeedSource
      LikeFetcher.fetch_for_news_items(self)
      self.score!
      save
    end
  end

  def score!
    base = [ source.value, xing * 3, linkedin * 2, retweets, fb_likes / 2, gplus, (incoming_link_count || 0) * 2].reject(&:blank?).reduce(:+)
    parallel_news_count = [source.news_items.current.count, 2 ].min
    base -= (parallel_news_count - 2) * 2

    time_factor = (published_at.to_i - MAX_AGE.ago.to_i) / (Time.now.to_i - MAX_AGE.ago.to_i).to_f
    self.absolute_score = score
    self.value = base * time_factor
  end

  def to_partial_path
    "news_items/#{source.class.model_name.element}_item"
  end

end
