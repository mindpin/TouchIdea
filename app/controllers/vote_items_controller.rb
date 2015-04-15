class VoteItemsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token, only: [:create, :praise]
  def create
    @vote = Vote.find params[:vote_id]
    @vote_item = @vote.vote_items.create vote_item_params.merge(user: current_user)
    respond_to do |format|
      format.json { render json: @vote_item.valid? ? @vote_item : @vote_item.errors}
      format.js
    end
  end

  private
  def vote_item_params
    params.require(:vote_item).permit(:title)
  end
end
