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
    Alle **LINKS** eines Twitter Accounts werden gefolgt und die Inhalte verarbeitet. Nutzt eine eigene URL Whitelist falls notwendig um keine Fremdinhalte einzutragen.
  DOC

  def refresh
    nil
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
  end
end
