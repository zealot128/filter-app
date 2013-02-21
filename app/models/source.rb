class Source < ActiveRecord::Base
  has_many :news_items, dependent: :destroy
  validates_presence_of :url, :name



  def self.cronjob
    Source.find_each do |t|
      t.refresh
    end
    NewsItem.cronjob
  end

  def refresh
    raise "NotImplementedError"
  end
end
