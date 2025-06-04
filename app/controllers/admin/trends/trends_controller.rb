class Admin::Trends::TrendsController < AdminController
  load_and_authorize_resource class: "Trends::Trend"

  def index
    @trends = Trends::Trend.includes(:words).order('name')
  end

  def new
    if params[:word]
      @word = Trends::Word.find(params[:word])
      all_words = @word.word.split(' ').reduce(Trends::Word.none) { |sql, i| sql.or(Trends::Word.where('word like ?', "%#{i}")) }
      @other_words = all_words.where.not(id: @word.id).
        joins(:usages).
        group(:id).
        order('count_all desc').
        limit(100).
        select('trends_words.*, count(*) as count_all')
      @trend = Trends::Trend.new(name: @word.word, words: [@word])
    else
      @trend = Trends::Trend.new(words: [])
      @other_words = []
    end
    @referer = URI.parse(request.referer).tap { |i| i.host = i.scheme = i.port = nil }.to_s if request.referer
    @referer = params[:back] if params[:back]
  end

  def create
    if @trend.save
      redirect_to params[:back].presence || '/admin/trends', notice: "saved"
    else
      render html: "Nope", layout: true
    end
  end

  def edit
  end

  def update
    if @trend.update(resource_params)
      redirect_to '/admin/trends', notice: "saved"
    else
      render html: "Nope", layout: true
    end
  end

  private

  def resource_params
    params.require(:trends_trend).permit!
  end
end
