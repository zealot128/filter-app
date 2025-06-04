RSpec.describe Newsletter::Inactivity do
  before(:each) do
    Setting.set('inactive_months', 12)
    load 'db/migrate/20190920075101_add_reminder_mail_settings.rb'
    AddReminderMailSettings.new.data
  end

  let(:delete_date) { Time.zone.now }
  let!(:mail_subscription) { Fabricate(:mail_subscription, created_at: delete_date - 12.months) }

  specify 'Integration in bestehendes System. Lange abgemeldete Nutzer neu erinnern' do
    mail_subscription.update(created_at: 2.years.ago)
    Newsletter::Inactivity.cronjob
    Newsletter::Inactivity.cronjob
    expect(ActionMailer::Base.deliveries.count).to be == 1
    expect(mail_subscription.reload).to_not be_unsubscribed
    Timecop.travel 2.weeks.from_now do
      Newsletter::Inactivity.cronjob
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 2
      expect(mail_subscription.reload).to_not be_unsubscribed
    end
    Timecop.travel 3.weeks.from_now do
      Newsletter::Inactivity.cronjob
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 3
      expect(mail_subscription.reload).to_not be_unsubscribed
    end
    Timecop.travel 4.weeks.from_now do
      Newsletter::Inactivity.cronjob
      expect(ActionMailer::Base.deliveries.count).to be == 4
      expect(mail_subscription.reload).to be_unsubscribed
    end
  end

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
    Timecop.travel 1.day.from_now do
      Newsletter::Inactivity.cronjob
    end
    expect(ActionMailer::Base.deliveries.count).to be == 4
    expect(mail_subscription.reload).to be_unsubscribed
    Timecop.travel 3.days.from_now do
      Newsletter::Inactivity.cronjob
    end
    expect(ActionMailer::Base.deliveries.count).to be == 4
  end

  specify 'letzten Klick bzw. öfnnung aus History berücksichten'
  # mail_subscription.histories.create!(created_at: 9.months.ago, opened_at: 9.months.ago, click_count: 1)
  # mail_subscription.histories.create!(created_at: 7.months.ago)
  # mail_subscription.histories.create!(created_at: 5.months.ago)
  # mail_subscription.histories.create!(created_at: 2.months.ago)
end
