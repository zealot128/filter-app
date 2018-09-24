class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :hash_tag
  attribute :logo

  def logo
    return nil unless object.logo.attached?
    {
      thumb: Rails.application.routes.url_helpers.rails_representation_url(object.logo.variant(resize: '100x100>'), host: Setting.host, protocol: :https),
      full:  Rails.application.routes.url_helpers.rails_blob_url(object.logo, host: Setting.host, protocol: :https)
    }
  end
end
