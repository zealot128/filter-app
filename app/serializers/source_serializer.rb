class SourceSerializer < SourcePreviewSerializer
  attributes :remote_url, :top_categories
  belongs_to :default_category
  attribute :statistics
  type "source"

  def statistics
    object.statistics&.except('top_categories') || {}
  end

  def top_categories
    object.statistics&.fetch('top_categories')
  end
end
