class AddMailOutroToSettings < ActiveRecord::Migration
  def change
  end

  def data
    Setting.where(key: 'mail_outro').first_or_create(value: <<-DOC.strip_heredoc)
		Die Newsletter Einstellungen können <a href='/newsletter'>hier</a> vorgenommen werden.<br/><br/>Haben Sie Anregungen, dann kontaktieren Sie mich unter {{person_email}}.<br/><br/>Viele Grüße<br/><br/>{{person}}
	DOC
  end
end
