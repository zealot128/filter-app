class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key
      t.text :value
    end
    add_index :settings, :key, unique: true
  end

  def data
    puts "Creating settings from config"
    Setting.read_yaml
  end
end
