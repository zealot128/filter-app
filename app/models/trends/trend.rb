# == Schema Information
#
# Table name: trends_trends
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string
#
# Indexes
#
#  index_trends_trends_on_slug  (slug) UNIQUE
#

class Trends::Trend < ApplicationRecord
  has_many :words, class_name: "Trends::Word"

  scope :top_of_n_days, ->(time, min_mentions) {
    joins(words: :usages).
      where(date: time..).
      group('trends_trends.id').
      order('count desc').
      having('count(distinct source_id) >= ?', min_mentions).
      select('trends_trends.*, count(distinct source_id) as count')
  }

  acts_as_url :name, url_attribute: :slug
  attr_accessor :extra_words

  before_save if: :extra_words do
    extra_words.split(',').map(&:strip).map(&:downcase).each do |w|
      word = Trends::Word.find_by(word: w)
      if word && words.exclude?(word)
        self.words << word
      end
    end
  end

  def news_items
    NewsItem.where(id: words.joins(:usages).select('news_item_id'))
  end

  def include_word?(word)
    words.any? { |i| i.word == word }
  end
end
