class Category < ActiveRecord::Base
  has_and_belongs_to_many :news_items
  scope :sorted, -> { order :name }

  def matches?(text)
    self.keywords.split(',').any? do |keyword|
      text.downcase[ %r{(^|\W)#{Regexp.escape(keyword.downcase)}($|\W)}]
    end
  end

  def self.select_collection
    sorted.to_a.map{|i| [i.name, i.id]} + [ ['Unkategorisiert', 0]]
  end
end
