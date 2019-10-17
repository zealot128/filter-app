class Admin::Trends::TrendsController < AdminController
  load_and_authorize_resource class: "Trends::Trend"

  def index
    @trends = Trends::Trend.includes(:words).all
  end

  def new
    @word = Trends::Word.find(params[:word])
    @other_words = []
    @word.word.split(' ').each do |word|
      @other_words += Trends::Word.where('word like ?', "%#{word}")
    end
    @other_words -= [@word]
    @other_words.uniq!
    @trend = Trends::Trend.new(name: @word.word, words: [@word])
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
