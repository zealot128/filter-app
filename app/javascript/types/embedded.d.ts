type NewsItem = {
  id: number
  title: string
  teaser: string
  url: string
  source_id: number
  published_at: string
  value: number
  fb_likes: null
  retweets: null
  guid: string
  xing: null
  created_at: string
  updated_at: string
  full_text: null
  word_length: null
  plaintext: null
  search_vector: string
  incoming_link_count: null
  absolute_score: number
  blacklisted: boolean
  reddit: null
  image_file_name: null
  image_content_type: null
  image_file_size: null
  image_updated_at: null
  impression_count: number
  tweet_id: null
  absolute_score_per_halflife: number
  youtube_likes: number
  youtube_views: number
  category_order: null
  dupe_of_id: null
  trend_analyzed: boolean
  paywall: boolean
  media_url: string
  embeddable: boolean
  image_url_full: string
  gplus: number
  linkedin: number
}

type Source = {
  id: number
  name: string
  homepage_url: string
  lsr_active: boolean
  language: string
  twitter_account: string
  type: string
  url: string
  logo: {
    thumb: string
    full: string
  } | null
  remote_url: string
  top_categories: TopCategory[]
  statistics: {
    total_news_count: number
    average_word_length: number
    current_news_count: number
    current_top_score: number
    last_posting: string
    current_impression_count: number
  }
  default_category: DefaultCategory
}

type DefaultCategory = {
  id: number
  name: string
  hash_tag: string
  slug: string
}

type TopCategory = {
  name: string
  count: number
}
