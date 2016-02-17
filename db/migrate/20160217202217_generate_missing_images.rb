class GenerateMissingImages < ActiveRecord::Migration
  def change
  end
  def data
    NewsItem.visible.each do |ni|
      ni.image.reprocess!
    end
  end
end
