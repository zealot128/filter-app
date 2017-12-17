# == Schema Information
#
# Table name: linkages
#
#  id         :integer          not null, primary key
#  from_id    :integer
#  to_id      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  different  :boolean          default(FALSE)
#

class Linkage < ActiveRecord::Base
  belongs_to :from, class_name: 'NewsItem', foreign_key: 'from_id'
  belongs_to :to, class_name: 'NewsItem', foreign_key: 'to_id'
  scope :different, -> { where different: true }
end
