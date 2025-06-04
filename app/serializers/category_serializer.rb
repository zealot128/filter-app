class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :hash_tag, :slug
  attribute :logo

  def logo
    return nil unless object.logo.attached?
    host = Rails.env.production? ? Setting.host : "hrfilter.#{ENV.fetch('LOGNAME', nil)}.pludoni.com"
    {
      thumb: Rails.application.routes.url_helpers.rails_representation_url(object.logo.variant(resize: '100x100>'), host:, protocol: :https),
      full:  Rails.application.routes.url_helpers.rails_blob_url(object.logo, host:, protocol: :https)
    }
  end
end
