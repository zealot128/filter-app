class AddImageCandidatesToSources < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :image_candidates, :string, array: true
  end
end
