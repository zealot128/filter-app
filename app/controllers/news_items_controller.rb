class NewsItemsController < ApplicationController
  before_action :stop_bad_crawler!, only: [:index, :homepage]

  def index
    minscore = 0.5
    @feed_url = search_url(q: params[:q], sort: params[:sort], format: :rss)
    if params[:q].present?
      @news_items = NewsItem.where('published_at > ?', 2.years.ago).
                             includes(:source, :categories).
                             search_full_text(params[:q]).
                             with_pg_search_rank.where('rank > ?', minscore)
      case params[:order]
      when 'recent'
        @news_items = @news_items.reorder('published_at desc')
      when 'score'
        @news_items = @news_items.reorder('absolute_score desc')
      end

      respond_to do |f|
        f.html {
          @news_items = @news_items.paginate(page: params[:page], per_page: 40)
        }
        f.rss {
          @news_items = @news_items.limit(50)
        }
      end
    else
      respond_to do |f|
        f.html
        f.rss {
          @news_items = NewsItem.home_page.limit(100)
        }
      end
    end
  end

  def show
    news_item = NewsItem.find(params[:id])
    if params[:sid]
      @current_user = MailSubscription.find_by(id: params[:sid])
      last_mail = @current_user.histories.order('created_at desc').first
      last_mail && last_mail.click!
    end
    unless bot?
      ahoy.track 'news_item', id: news_item.id, source_id: news_item.source_id
      impressionist(news_item)
    end
    redirect_to news_item.url
  end

  def homepage
    @news_items = NewsItem.home_page.limit(36).page(page)
    if params[:category].present?
      @news_items = case params[:category].to_i
                    when 0
                      @news_items.uncategorized
                    when -1
                      @news_items
                    else
                      @news_items.joins(:categories).where(categories: { id: params[:category] }).group('news_items.id')
                    end
    end
    case params[:order]
    when 'recent'
      @news_items = @news_items.reorder('published_at desc')
    when 'score'
      @news_items = @news_items.reorder('absolute_score desc')
    end
    render json: {
      html: render_to_string('homepage.html', layout: false),
      pagination: {
        total_pages: @news_items.total_pages,
        total_entries: @news_items.total_entries
      }
    }
  end

  private

  def bot?
    IPCat.datacenter?(request.ip) || request.bot?
  end

  def page
    [1, params[:page].to_i].max
  end
end
