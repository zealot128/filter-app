class AddJobUrlSettings < ActiveRecord::Migration[5.2]
  def change
    Setting.set('jobs_url', 'https://login.empfehlungsbund.de/api/v2/jobs/search.json?q=personal%20hr&fair=false&min_score=1.2&portal_types=office&per=50')
  end
end
