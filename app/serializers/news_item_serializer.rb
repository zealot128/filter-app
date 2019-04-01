class NewsItemSerializer < ApplicationSerializer
  attributes :id, :title, :teaser, :url, :published_at, :word_length
  attribute :score
  attribute :image
  attribute :categories
  attribute :category_objects
  attribute :original_url
  has_one :source, serializer: SourcePreviewSerializer

  def url
    click_proxy_url(object, host: Setting.host, protocol: 'https')
  end

  def original_url
    object.url
  end

  def categories
    object.categories.map(&:name)
  end

  def category_objects
    object.categories.map { |c|
      c.as_json.except('created_at', 'updated_at', 'keywords')
    }
  end

  def score
    {
      current_score: object.value,
      absolute_score: object.absolute_score.round(1),
      googleplus: object.gplus,
      linkedin: object.linkedin,
      xing: object.xing,
      facebook: object.fb_likes,
      twitter: object.retweets,
      reddit: object.reddit,
      impressions: object.impression_count,
      internal_links: object.incoming_link_count,
    }
  end

  def image
    if object.image.present?
      {
        full_url: object.image_url_full
      }
    else
      {}
    end
  end
end
