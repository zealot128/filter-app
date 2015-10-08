class Linkage < ActiveRecord::Base
  belongs_to :from, class_name: 'NewsItem', foreign_key: 'from_id'
  belongs_to :to, class_name: 'NewsItem', foreign_key: 'to_id'
  scope :different, -> { where different: true }
end
