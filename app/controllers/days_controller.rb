class DaysController < ApplicationController
  def index
    @paths = {
      "Suche/Feeds": search_path,
      "Impressum": impressum_path,
      "Datenschutz": datenschutz_path,
      "FAQ": faq_path,
      "Quellen": '/quellen',
      "Quelle einreichen": new_submit_source_path,
      "Als App": app_path,
      "Newsletter": '/newsletter'
    }
    @twitter = "#{Setting.get('twitter_account')}" || ""
  end

  def show
    @day = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    if @day > Date.today
      raise ArgumentError
    end
    @news = NewsItem.includes(:source).top_of_day(@day)
    @tomorrow = @day + 1
    if @tomorrow > Date.today
      @tomorrow = nil
    end
    @yesterday = @day - 1
    respond_to do |f|
      f.html
      f.js {
        @news_item_template = render_to_string(@news)
      }
    end
  rescue ArgumentError
    render html: "<h3>Ungültiges Datum</h3>", layout: true, status: 400
  end
end
