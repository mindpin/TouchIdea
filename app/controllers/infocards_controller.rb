class InfocardsController < ApplicationController
  def parse_url
    infocard = Infocard.parse(params[:url])
    render json: {
      id: infocard.id.to_s,
      html: (render_cell :topics, :infocard, infocard)
    }
  end
end