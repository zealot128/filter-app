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

class RedditSource < Source
  self.description = <<~DOC
    Name muss ein Subreddit sein, dass eingebunden wird
  DOC
  before_validation :set_url

  def refresh
    RedditProcessor.process(self)
  end

  def set_url
    self.url = "https://www.reddit.com/r/#{name}"
  end

  def download_thumb
    return if Rails.env.test?

    doc = Nokogiri.parse(open(host, redirect: true, allow_redirections: :all))
    img = doc.at('#header-img')
    return if img.blank? or img['src'].blank?

    logo_url = "https:#{img['src']}"
    update logo: download_url(logo_url)
  end

  def should_fetch_stats?(ni)
    ni.url.exclude?("www.reddit.com/r/#{name}")
  end
end
