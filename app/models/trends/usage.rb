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
#  index_trends_usages_on_calendar_week  (calendar_week)
#  index_trends_usages_on_date           (date)
#  index_trends_usages_on_dupe           (dupe)
#  index_trends_usages_on_news_item_id   (news_item_id)
#  index_trends_usages_on_source_id      (source_id)
#  index_trends_usages_on_usage_type     (usage_type)
#  index_trends_usages_on_word_id        (word_id)
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
end
