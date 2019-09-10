RSpec.describe Newsletter::Inactivity do
  before(:each) do
    Setting.set('inactive_months', 12)
    load 'db/migrate/20190920075101_add_reminder_mail_settings.rb'
    AddReminderMailSettings.new.data
  end

  let(:delete_date) { Time.zone.now }
  let!(:mail_subscription) { Fabricate(:mail_subscription, created_at: delete_date - 12.months) }

  specify 'integrationstest - Neue Nutzer fruehestens nach 6 Monaten - 14 Tage erinnern', type: :request do
    Timecop.travel 14.days.ago do
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 1
      expect(ActionMailer::Base.deliveries.first.to).to be == [mail_subscription.email]

      Newsletter::Inactivity.cronjob

      expect(ActionMailer::Base.deliveries.count).to be == 1
    end

    Timecop.travel 3.days.ago do
      Newsletter::Inactivity.cronjob
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 2
    end

    Timecop.travel 1.day.ago do
      Newsletter::Inactivity.cronjob
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 3
    end

    link = Nokogiri::HTML.fragment(ActionMailer::Base.deliveries.last.html_part.body.decoded.to_s).at('a')['href']
    get link
    expect(mail_subscription.reload.last_reminder_sent_at).to be == nil

    # jetzt save, kriegt keine erinnerung mehr
    Newsletter::Inactivity.cronjob
    expect(ActionMailer::Base.deliveries.count).to be == 3

    # 1 jahr spaeter geht alles von vorne los
    Timecop.travel 360.days.from_now do
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 4
      expect(mail_subscription.reload.last_reminder_sent_at).to_not be == nil
    end
  end

  specify 'loeschen wenn nicht geklickt' do
    Timecop.travel 14.days.ago do
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 1
    end
    Timecop.travel 3.days.ago do
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 2
    end
    Timecop.travel 1.day.ago do
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 3
    end
    Newsletter::Inactivity.cronjob
    expect(ActionMailer::Base.deliveries.count).to be == 4
    expect(mail_subscription.reload).to be_unsubscribed
  end

  specify 'letzten Klick bzw. öfnnung aus History berücksichten'
  # mail_subscription.histories.create!(created_at: 9.months.ago, opened_at: 9.months.ago, click_count: 1)
  # mail_subscription.histories.create!(created_at: 7.months.ago)
  # mail_subscription.histories.create!(created_at: 5.months.ago)
  # mail_subscription.histories.create!(created_at: 2.months.ago)
end
