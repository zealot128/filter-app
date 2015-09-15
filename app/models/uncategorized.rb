class Uncategorized
  def id
    0
  end

  def name
    'Unkategorisiert'
  end

  def news_items
    NewsItem.uncategorized
  end
end
