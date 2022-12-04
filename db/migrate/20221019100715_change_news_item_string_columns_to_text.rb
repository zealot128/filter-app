class ChangeNewsItemStringColumnsToText < ActiveRecord::Migration[6.0]
  def change
    change_column :news_items, :title, :string

    change_column :news_items, :url, :string, limit: 2048, using: "substring(url from 1 for 2048)"
  end
end
