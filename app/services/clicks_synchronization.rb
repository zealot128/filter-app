class ClicksSynchronization
  def self.run
    return if Setting.get('clicks_api').blank?

    Ahoy::Visit.
      where(synced: false).
      where(started_at: ...4.hours.ago).
      joins(:events).
      group(:id).find_each do |visit|
      sync_visit(visit)
    end

    cleanup
  end

  def self.sync_visit(visit)
    return unless visit.events.any?

    payload = { origin: Setting.host, visit: visit.as_json(include: :events), api_key: Setting.get('clicks_api_token') }
    HTTParty.post(Setting.get('clicks_api'), body: payload, basic_auth: { username: 'test', password: '1t5a#', timeout: 50 })
    visit.update_column(:synced, true)
  end

  def self.cleanup
    no_events_at_all = Ahoy::Visit.where(started_at: ...7.days.ago).left_joins(:events).where(ahoy_events: { id: nil }).pluck('ahoy_visits.id')
    if no_events_at_all.present?
      Ahoy::Visit.where(id: no_events_at_all).destroy_all
    end
    Ahoy::Visit.where(started_at: ...6.months.ago).destroy_all
  end
end
