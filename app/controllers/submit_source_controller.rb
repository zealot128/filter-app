class SubmitSourceController < ApplicationController
  before_action do
    @title = 'Quelle einreichen'
  end

  def new
    @submit_source = SubmitSource.new
  end

  def create
    @submit_source = SubmitSource.new(params[:submit_source])
    @submit_source.request = request
    if @submit_source.deliver
      flash.now[:error] = nil
    else
      flash.now[:error] = "Cannot submit source."
      render :new
    end
  end
end
