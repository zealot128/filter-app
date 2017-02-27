class SourcePreviewSerializer < ApplicationSerializer
  attributes :id, :name, :homepage_url, :lsr_active, :language, :twitter_account
  attributes :type

  attribute :logo

  def logo
    if object.logo.present?
      "https://#{Setting.host}" + object.logo.url(:small)
    else
      nil
    end
  end

end
