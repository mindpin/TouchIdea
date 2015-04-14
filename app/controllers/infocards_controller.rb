class InfocardsController < ApplicationController
  before_filter :authenticate_user!

  def create
    infocard = Infocard.parse(params[:url])
    render :json => {
      :title    => infocard.title,
      :pictures => infocard.pictures,
      :price    => infocard.price
    }
  end
end