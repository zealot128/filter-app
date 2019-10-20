# == Schema Information
#
# Table name: trends_usages
#
#  id            :bigint(8)        not null, primary key
#  word_id       :integer
#  news_item_id  :bigint(8)
#  source_id     :bigint(8)
#  calendar_week :string
#  date          :date
#  usage_type    :integer          default("title")
#  dupe          :boolean          default(FALSE)
#
# Indexes
#
#  index_trends_usages_on_dupe          (dupe)
#  index_trends_usages_on_news_item_id  (news_item_id)
#  index_trends_usages_on_source_id     (source_id)
#  index_trends_usages_on_usage_type    (usage_type)
#  index_trends_usages_on_word_id       (word_id)
#
# Foreign Keys
#
#  fk_rails_...  (news_item_id => news_items.id)
#  fk_rails_...  (source_id => sources.id)
#

class Trends::Usage < ActiveRecord::Base
  belongs_to :word, class_name: "Trends::Word"
  belongs_to :news_item
  belongs_to :source
  enum usage_type: [:title, :plaintext]

  def self.find_trends
    weeks = Trends::Usage.group(:calendar_week).order('calendar_week desc').count.keys.take(12)
    results = weeks.map do |week|
      [week, Trends::Usage.where(calendar_week: week).joins(:word).where('ignore = ? and parent_id is null', false).group('trends_words.word').order('count_all desc').limit(200).count.delete_if{|k,v| v < 8 }]
    end

    ahead = 4
    top_words = results.map do |element|
      week, words_in_week = element
      index = results.find_index(element)
      words_other_weeks = (results.slice((index-ahead)...index) + results.slice(index+1..index+ahead)).map(&:last).map(&:keys).flatten.uniq
      tops = words_in_week.except(*words_other_weeks)
      [week, tops.delete_if{|k,v| v < 10 }.take(10)]
    end
    binding.pry
  end
end
