class AddMailIntroToSettings < ActiveRecord::Migration
  def change
  end

  def data
    Setting.where(key: 'mail_intro').first_or_create(value: <<-DOC.strip_heredoc)
      hier die Top {{top}} von insgesamt {{total_count}} der relevantesten News aus letzter Woche aus den abonnierten Themenbereichen <strong>{{categories}}</strong>.
    DOC
  end
end
