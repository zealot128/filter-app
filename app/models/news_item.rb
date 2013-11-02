require "fetcher"
class NewsItem < ActiveRecord::Base
  has_and_belongs_to_many :categories
  belongs_to :source
  validates_uniqueness_of :guid, scope: [:source_id]

  scope :current, -> { where("published_at > ?", FetcherConcern::MAX_AGE.ago) }
  scope :home_page, -> { order("value desc").where("value is not null").current }

  include FetcherConcern

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
      freshness:  (published_at.to_i - FetcherConcern::MAX_AGE.ago.to_i) / 10000,
      bias: source.value,
      words: word_length,
    }
  end

  before_save :categorize
  def categorize
    if plaintext
      self.categories = Category.all.select{|i|
        i.matches?(plaintext)
      }
    end
  end
  before_save do
    self.word_length = words.length
  end

  def plaintext
    ActionController::Base.helpers.strip_tags(full_text || teaser || title)
  end

  def words
    plaintext.split(/[^\p{Word}]+/)
  end

  def refresh
    if source.is_a? FeedSource
      fetch_linkedin
      fetch_twitter
      fetch_facebook
      fetch_xing
      fetch_gplus
      self.value = score
      save
    end
  end

end
