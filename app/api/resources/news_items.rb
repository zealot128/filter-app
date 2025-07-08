class Resources::NewsItems < Grape::API
  include BaseAPI
  namespace :news_items do
    params do
      optional :from, Date
      optional :to, Date
      optional :page, Integer, default: 1
      optional :limit, Integer, default: 30
      optional :source_id, Integer
      optional :preferred, String
      optional :blacklisted, String
      optional :teaser_enabled, Boolean
      optional :image_exists, Boolean
      optional :categories, String
      optional :order, String,
desc: "Order by, default hot_score, other option: best - best 33% news per day (same as filter homepage), week_best, month_best, newest"
      optional :query, String, desc: "Search term"
      optional :media_type, String
    end
    get '/' do
      filter = NewsFilter.new(
        to: params[:to],
        query: params[:query],
        from: params[:from],
        preferred: params[:preferred],
        blacklisted: params[:blacklisted],
        teaser_enabled: params[:teaser_enabled],
        image_exists: params[:image_exists],
        per_page: params[:limit],
        page: params[:page],
        categories: params[:categories],
        order: params[:order],
        media_type: params[:media_type]
      )
      @news_items = filter.news_items
      if params[:source_id]
        @news_items = @news_items.where(source_id: params[:source_id])
      end
      render @news_items, meta: { total_count: @news_items.total_entries, pages: @news_items.total_pages, current_page: @news_items.current_page }
    end
  end

  namespace :categories do
    get '/' do
      Category.sorted
    end
  end

  namespace :sources do
    params do
      optional :category_id, Integer
    end
    get '/' do
      base = Source.visible.includes(:default_category).order('name')
      if Setting.get('promoted_feed_id').present?
        base.where.not(id: Setting.promoted_feed_id)
      end
      if params[:category_id]
        base = base.where(default_category_id: params[:category_id])
      end
      base
    end
    get '/media-types' do
      ignore = %w(TwitterSource RedditSource FacebookSource)
      Source::SOURCE_TYPES.reject { |el| ignore.include?(el) }.as_json
    end
    get '/:id' do
      Source.visible.find(params[:id])
    end
  end

  namespace :eb_youtube do
    get '/' do
      source = YoutubeSource.find_by(name: "Empfehlungsbund")
      if source.present?
        nis = source.news_items.current
        nis = source.news_items.recent if nis.blank?
      end
      return error!({ status: "not_found" }, 404) if nis.blank?

      nis = nis.map { |ni| ni.attributes.slice('title', 'url') }
      { news_items: nis, status: 'ok' }
    end
  end
end
