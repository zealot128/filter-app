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

class TwitterSource < Source
  self.description = <<~DOC
    Alle News eines Twitter Accounts
  DOC

  def refresh(take: 50)
    TwitterProcessor.process(self)
    update_column :error, false
  rescue StandardError => e
    if Rails.env.test?
      raise e
    else
      NOTIFY_EXCEPTION(e)
      update_column :error, true
      update_column :error_message, e.inspect
    end
  end

  def to_param
    "#{id}-#{user_name.to_url}"
  end

  def user_name
    url.delete('@')
  end

  def user
    TwitterSource.client.user(url.delete('@'))
  end

  def download_thumb
    path = user.profile_image_url.to_s
    update logo: download_url(path)
  end

  def remote_url
    "https://twitter.com/#{user_name}"
  end

  def self.client
    @client ||= ::Twitter::REST::Client.new do |config|
      config.consumer_key =      Rails.application.secrets.twitter_consumer_key
      config.consumer_secret =   Rails.application.secrets.twitter_consumer_secret
      config.access_token =        Setting.get('twitter_access_token') || Rails.application.secrets.twitter_access_token
      config.access_token_secret = Setting.get('twitter_access_secret') || Rails.application.secrets.twitter_access_token_secret
    end
  end
end
