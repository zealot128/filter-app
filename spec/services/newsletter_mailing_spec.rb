require "spec_helper"

describe 'NewsletterMailing' do
  let(:subscription) {
    MailSubscription.create!(
      email: 'stwienert@gmail.com',
      categories: [category.id],
      limit: 50,
      interval: 'weekly'
    )
  }
  let(:category) {
    Category.create!(name: 'Gehalt', keywords: '')
  }
  specify 'tracks send status so no duplicate send' do
    subscription.confirm!

    # Keine Mail, wenn nichts neues
    Newsletter::Mailing.cronjob
    ActionMailer::Base.deliveries.count.should be == 0

    import_stuff!
    # 1 news da, mail geht raus
    Newsletter::Mailing.cronjob
    ActionMailer::Base.deliveries.count.should be == 1

    # nochmal ausgefuehrt -> geht nicht, da Datum gesetzt
    Newsletter::Mailing.cronjob
    ActionMailer::Base.deliveries.count.should be == 1

    Timecop.travel 7.days.from_now
    Newsletter::Mailing.cronjob
    # Keine neuen News
    ActionMailer::Base.deliveries.count.should be == 1

    @ni.update_columns published_at: 2.days.ago
    Newsletter::Mailing.cronjob
    ActionMailer::Base.deliveries.count.should be == 2
    Timecop.return
  end

  specify 'adds newly added categories, even if not subscribed' do
    subscription.confirm!
    import_stuff!

    Category.create!(name: 'NewCategoryOk', keywords:'')
    Category.create!(name: 'NewCategoryTooOld', keywords:'', created_at: 14.days.ago)
    Newsletter::Mailing.cronjob
    ActionMailer::Base.deliveries.count.should be == 1

    body = ActionMailer::Base.deliveries.first.html_part.body.to_s
    expect(body).to include "NewCategoryOk"
    expect(body).to_not include "NewCategoryTooOld"
  end

  def import_stuff!
    VCR.use_cassette 'feed-pludoni.xml' do
      source = FeedSource.create!(url: 'http://www.pludoni.de/posts/feed.rss', name: 'pludoni')
      source.refresh
      source.news_items.count.should be > 0
      @ni = source.news_items.first
      @ni.categories << category
      @ni.update_columns absolute_score: 100, published_at: 2.days.ago
    end
  end
end
