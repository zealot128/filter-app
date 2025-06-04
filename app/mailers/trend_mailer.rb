class TrendMailer < ApplicationMailer
  layout 'newsletter'
  default from: Setting.get('from')

  def week_trends(trends)
    if trends.length == 0
      return
    end
    @trends = trends
    mail to: Setting.get('person_email'), subject: "[#{Setting.site_name}] Trends der letzten Woche"
  end
end
