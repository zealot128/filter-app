# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  keywords   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  hash_tag   :string
#

class Category < ActiveRecord::Base
  has_and_belongs_to_many :news_items
  scope :sorted, -> { order :name }
  validates :name, presence: true

  def matches?(text)
    keywords.split(',').any? do |keyword|
      text.downcase[/(^|\W)#{Regexp.escape(keyword.downcase)}($|\W)/]
    end
  end

  before_save do
    if !hash_tag?
      self.hash_tag = name.gsub(' ', '')
    end
  end

  def self.select_collection
    sorted.to_a.map { |i| [i.name, i.id] } + [['Unkategorisiert', 0]]
  end
end
