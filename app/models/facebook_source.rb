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
#

class FacebookSource < Source
  def refresh
    FacebookProcessor.new.run_all(self)
  end

  def download_thumb
    url = agent.page.at('meta[property*=image]')['content']
    agent.get(url)
    Tempfile.open(['download_thumb', agent.page.response['content-type'].split('/').last]) do |tf|
      tf.binmode
      tf.write(agent.page.body)
      tf.flush
      tf.rewind
      update logo: tf
    end
  rescue StandardError => e
    p e
    nil
  end

  def remote_url
    "https://www.facebook.com/#{url}/" #personalwirtschaft.de/?fref=nf
  end

  def agent
    return @m if @m
    @m ||= Mechanize.new
    @m.get(remote_url)
    @m
  end
end
