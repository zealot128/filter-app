# == Schema Information
#
# Table name: trends_words
#
#  id        :bigint(8)        not null, primary key
#  word      :string
#  parent_id :integer
#  ignore    :boolean
#  word_type :integer          default("single")
#  trend_id  :integer
#
# Indexes
#
#  index_trends_words_on_trend_id  (trend_id)
#

class Trends::Word < ActiveRecord::Base
  has_and_belongs_to_many :categories,
                          join_table: 'categories_trends_words',
                          class_name: 'Category',
                          foreign_key: 'trends_word_id',
                          association_foreign_key: 'category_id'
  belongs_to :parent, class_name: 'Trends::Word'
  belongs_to :trend, class_name: "Trends::Trend"
  has_many :children, class_name: "Trends::Word", foreign_key: "parent_id"

  enum word_type: [:single, :bigram, :trigram]
  has_many :usages, class_name: "Trends::Usage", foreign_key: "word_id", dependent: :destroy
  scope :root, -> { where(parent_id: nil) }
  scope :visible, -> { where.not(ignore: true) }

  before_save do
    self.word_type = case word.count(' ')
                     when 1 then 'bigram'
                     when 2 then 'trigram'
                     else 'single'
                     end
  end

  def top_parent
    if parent
      parent.top_parent
    else
      self
    end
  end

  def self.merge
    rules = [
      ['%en', /en$/],
      ['%e', /e$/],
      ['%rem', /m$/],
      ['%res', /s$/],
      ['%ren', /n$/],
      ['%rer', /r$/],
      ['%res', /s$/],
      ['%ers', /s$/],
      ['%erm', /m$/],
      ['%ern', /n$/],
      ['%en', /n$/],
      ['%er', /r$/],
      ['%es', /s$/],
      ['%isse', /se$/],
      ['%er', /er$/],
      ['%s', /s$/],
    ]

    rules.each do |like, regex|
      Trends::Word.
        where(parent_id: nil).
        where('word like ?', like).
        where('length(word) > 3').
        map { |word| [word, Trends::Word.find_by(word: word.word.remove(regex))] }.
        select { |_, b| b }.each do |word, parent|
        word.parent = parent.top_parent
        word.usages.update_all word_id: word.parent.id
        word.children.each do |c|
          c.parent = word.parent
          c.save
          c.usages.update_all word_id: word.parent.id
        end
        word.save
      end
    end
    Trends::Word.where.not(parent_id: nil).where(ignore: true).reject { |i| i.parent.ignore? }.each do |word|
      word.parent.update ignore: true
      word.children.update_all ignore: true
    end
    Trends::Word.where(parent_id: nil).where(ignore: true).where(id: Trends::Word.where.not(parent_id: nil).where(ignore: false).select('parent_id')).each do |word|
      word.children.update_all ignore: true
    end
    Trends::Usage.where(word_id: Trends::Word.where(ignore: true).select('id')).delete_all
  end
end
