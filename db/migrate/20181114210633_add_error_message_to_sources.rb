class AddErrorMessageToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :error_message, :text
  end
end
