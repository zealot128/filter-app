require "spec_helper"

describe 'NewsletterMailing' do
  specify 'Newsletter Weekly' do
    category = Category.create!(name: 'Gehalt', keywords: '')
    subscription = MailSubscription.create!(
      email: 'stwienert@gmail.com',
      categories: [category.id],
      interval: 'weekly'
    )
    subscription.confirm!

    # Keine Mail, wenn nichts neues
    NewsletterMailing.cronjob
    ActionMailer::Base.deliveries.count.should be == 0

    ni = nil
    VCR.use_cassette 'feed-pludoni.xml' do
      source = FeedSource.create!(url: 'http://www.pludoni.de/posts/feed.rss', name: 'pludoni')
      source.refresh
      source.news_items.count.should be > 0
      ni = source.news_items.first
      ni.categories << category
      ni.update_columns absolute_score: 100, published_at: 2.days.ago
    end

    # 1 news da, mail geht raus
    NewsletterMailing.cronjob
    ActionMailer::Base.deliveries.count.should be == 1

    # nochmal ausgefuehrt -> geht nicht, da Datum gesetzt
    NewsletterMailing.cronjob
    ActionMailer::Base.deliveries.count.should be == 1

    Timecop.travel 7.days.from_now
    NewsletterMailing.cronjob
    # Keine neuen News
    ActionMailer::Base.deliveries.count.should be == 1

    ni.update_columns  published_at: 2.days.ago
    NewsletterMailing.cronjob
    ActionMailer::Base.deliveries.count.should be == 2
    Timecop.return
  end
end
