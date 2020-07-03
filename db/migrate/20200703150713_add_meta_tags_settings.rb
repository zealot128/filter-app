class AddMetaTagsSettings < ActiveRecord::Migration[6.0]
  def change
    Setting.set('meta_description', Setting.get('explanation'))
    Setting.set('meta_keywords', 'Aggregator, News')
  end
end
