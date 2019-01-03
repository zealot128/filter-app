class BscController < ApplicationController
  def show
    if params[:api_key] != Rails.application.secrets.statistic_api_key
      render plain: '401 - access denied', status: 401
      return
    end

    our_sources = Source.where('url like ? or url like ? ', '%pludoni%', '%empfehlungsbund%')
    time = 3.days.ago
    from = time.at_beginning_of_year
    to = time.at_end_of_year
    year = time.year
    subscriptions = MailSubscription.order('created_at desc')
    render json: {
      metrics: {
        "Klicks" => {
          clicks_total: {
            title: "Klicks auf alle Beiträge im Kalenderjahr #{year}",
            value: Impression.where('created_at between ? and ?', from, to).count
          },
          clicks_pludoni: {
            title: "Klicks auf pludoni Quellen",
            value: Impression.where('created_at between ? and ?', from, to).where(impressionable_id: NewsItem.where(source_id: our_sources).select('id')).count
          }
        },
        "Beiträge" => {
          news_items_total: {
            title: "Newsbeiträge in #{year}",
            value: NewsItem.where('extract(year from created_at) = ?', year).count
          },
          news_items_pludoni: {
            title: "Newsbeiträge von pludoni Quellen #{year}",
            value: NewsItem.where(source_id: our_sources).where('extract(year from created_at) = ?', year).count
          },
        },
        "Abonnenten" => {
          subscribers_total: {
            title: "Abonnenten insgesamt",
            value: subscriptions.count
          },
          subscribers_confirmed: {
            title: "Abonnenten bestätigt",
            percentage_of: :subscribers_total,
            value: subscriptions.confirmed.count
          },
          subscribers_with_clicks: {
            title: "Abonnenten mit min. 1 Klick in #{year}",
            percentage_of: :subscribers_confirmed,
            value: subscriptions.
              joins(:impressions).
              where('extract(year from impressions.created_at) = ?', year).
              count('distinct(mail_subscriptions.id)')
          }
        },
        "Quellen" => {
          sources_total: {
            title: "Quellen insgesamt",
            value: Source.visible.count
          },
          sources_no_error: {
            title: "Quellen ohne Fehler",
            value: Source.visible.where.not("error = ?", true).count,
            percentage_of: :sources_total
          },
          sources_new: {
            title: "Neue Quellen in #{year}",
            value: Source.visible.where('extract(year from created_at) = ?', year).count,
            percentage_of: :sources_total
          }
        },
        "Newsletter" => {
          newsletter_sent: {
            title: "Newsletter in #{year} versendet (Tracking seit 09.01.2018)",
            value: MailSubscription::History.where('extract(year from created_at) = ?', year).count
          },
          newsletter_opened: {
            title: "Newsletter in #{year} geöffnet/geklickt",
            value: MailSubscription::History.opened.where('extract(year from created_at) = ?', year).count,
            percentage_of: :newsletter_sent
          }
        }
      },
      users: {}
    }
  end
end
