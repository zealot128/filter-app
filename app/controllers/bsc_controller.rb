class BscController < ApplicationController
  def show
    if params[:api_key] != Rails.application.credentials.statistic_api_key
      render plain: '401 - access denied', status: 401
      return
    end

    our_sources = Source.where('url like ? or url like ? ', '%pludoni%', '%empfehlungsbund%')

    year = (params[:year].presence || 3.days.ago.year).to_i
    Date.new(year, 1, 1)
    Date.new(year, 12, 31)
    subscriptions = MailSubscription.order('created_at desc')
    render json: {
      metrics: {
        "Beiträge" => {
          news_items_total: {
            title: "Newsbeiträge im Kalenderjahr",
            determinable_for_past: true,
            value: NewsItem.where('extract(year from created_at) = ?', year).count
          },
          news_items_pludoni: {
            title: "Newsbeiträge von pludoni Quellen #{year}",
            determinable_for_past: true,
            value: NewsItem.where(source_id: our_sources).where('extract(year from created_at) = ?', year).count
          },
        },
        "Abonnenten" => {
          subscribers_new: {
            title: "Neue Abonnenten im Jahr",
            value: MailSubscription.where('extract(year from created_at) = ?', year).count,
            determinable_for_past: true,
          },
          subscribers_lost: {
            title: "Abonnenten abbestellt im Jahr",
            value: MailSubscription.deleted.where('extract(year from deleted_at) = ?', year).count,
            determinable_for_past: true,
          },
          subscribers_total: {
            title: "Abonnenten insgesamt",
            value: subscriptions.count
          },
          subscribers_confirmed: {
            title: "Abonnenten bestätigt",
            percentage_of: :subscribers_total,
            value: subscriptions.confirmed.count
          },
          active_subscribers_per_month: {
            title: "Anzahl aktive Abonnennten je Monat",
            determinable_for_past: true,
            value: MailSubscription::History.
              where.not(mail_subscription_histories: { opened_at: nil }).
              where('extract(year from mail_subscription_histories.created_at) = :year', year:).
              group_by_month('mail_subscription_histories.created_at').
              count('distinct(mail_subscription_id)')
          }
        },
        "Quellen" => {
          sources_total: {
            title: "Quellen insgesamt",
            value: Source.visible.count
          },
          sources_no_error: {
            title: "Quellen ohne Fehler",
            value: Source.visible.where.not(error: true).count,
            percentage_of: :sources_total
          },
          sources_new: {
            title: "Neue Quellen im Jahr",
            value: Source.visible.where('extract(year from created_at) = ?', year).count,
            determinable_for_past: true,
            percentage_of: :sources_total
          }
        },
        "Newsletter" => {
          newsletter_sent: {
            title: "Newsletter im Jahr versendet (Tracking seit 09.01.2018)",
            value: MailSubscription::History.where('extract(year from created_at) = ?', year).count
          },
          newsletter_opened: {
            title: "Newsletter im Jahr geöffnet/geklickt",
            value: MailSubscription::History.opened.where('extract(year from created_at) = ?', year).count,
            percentage_of: :newsletter_sent
          }
        }
      },
      users: {}
    }
  end
end
