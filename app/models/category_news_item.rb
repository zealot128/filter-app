# == Schema Information
#
# Table name: categories_news_items
#
#  category_id  :integer
#  news_item_id :integer
#
# Indexes
#
#  categories_news_items_index  (category_id,news_item_id) UNIQUE
#

class CategoryNewsItem < ActiveRecord::Base
  self.table_name = 'categories_news_items'

  belongs_to :news_item
  belongs_to :category
end
