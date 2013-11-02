class AddFullTextSelectorToSources < ActiveRecord::Migration
  def change
    add_column :sources, :full_text_selector, :string
  end
end
