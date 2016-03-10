class AddLanguageToSources < ActiveRecord::Migration
  def change
    add_column :sources, :language, :string
  end

  def data
    Source.update_all language: 'german'
    english = %w[
      http://blogs.hrhero.com/hrnews/feed/
      http://feeds.feedburner.com/hrcapitalist
      http://feeds.feedburner.com/HRExaminer
      http://feeds.feedburner.com/HRIQ]
    Source.where(url: english).update_all language: 'english'
  end
end
