# == Schema Information
#
# Table name: trends_words
#
#  id        :bigint(8)        not null, primary key
#  word      :string
#  ignore    :boolean
#  word_type :integer          default("single")
#  trend_id  :integer
#
# Indexes
#
#  index_trends_words_on_ignore    (ignore)
#  index_trends_words_on_trend_id  (trend_id)
#  index_trends_words_on_word      (word) UNIQUE
#

class Trends::Word < ActiveRecord::Base
  has_and_belongs_to_many :categories,
                          join_table: 'categories_trends_words',
                          class_name: 'Category',
                          foreign_key: 'trends_word_id',
                          association_foreign_key: 'category_id'
  belongs_to :trend, class_name: "Trends::Trend"

  enum word_type: [:single, :bigram, :trigram, :quadrogram]
  has_many :usages, class_name: "Trends::Usage", foreign_key: "word_id", dependent: :destroy
  scope :visible, -> { where.not(ignore: true) }

  before_save do
    self.word_type = case word.count(' ')
                     when 1 then 'bigram'
                     when 2 then 'trigram'
                     when 3 then 'quadrogram'
                     else 'single'
                     end
  end
end
