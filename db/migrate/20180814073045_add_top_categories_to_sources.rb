class AddTopCategoriesToSources < ActiveRecord::Migration
  def change
    add_column :sources, :statistics, :json
  end

  def data
    Source.find_each do |s|
      s.update_statistics!
    end
  end
end
