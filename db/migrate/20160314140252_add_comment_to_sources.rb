class AddCommentToSources < ActiveRecord::Migration
  def change
    add_column :sources, :comment, :text
  end
end
