# == Schema Information
#
# Table name: sources
#
#  id                            :integer          not null, primary key
#  type                          :string(255)
#  url                           :string(255)
#  name                          :string(255)
#  value                         :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  logo_file_name                :string(255)
#  logo_content_type             :string(255)
#  logo_file_size                :integer
#  logo_updated_at               :datetime
#  full_text_selector            :string(255)
#  error                         :boolean
#  multiplicator                 :float            default(1.0)
#  lsr_active                    :boolean          default(FALSE)
#  deactivated                   :boolean          default(FALSE)
#  default_category_id           :integer
#  lsr_confirmation_file_name    :string
#  lsr_confirmation_content_type :string
#  lsr_confirmation_file_size    :integer
#  lsr_confirmation_updated_at   :datetime
#  twitter_account               :string
#  language                      :string
#  comment                       :text
#  filter_rules                  :text
#  statistics                    :json
#  error_message                 :text
#

class YoutubeSource < Source
  self.description = <<~DOC
    Youtube-Kanal-URL.
  DOC
  validates :url, presence: true, format: { with: %r{\Ahttps://www.youtube.com/(user|channel|c)/[^ ]+\z} }

  def download_thumb
    doc = Nokogiri.parse(open(url))
    img = doc.search('meta[property="og:image"]').first["content"]
    return if img.blank?
    update logo: download_url(img)
  end

  def refresh
    YoutubeProcessor.new.process(self)
    true
  end
end
