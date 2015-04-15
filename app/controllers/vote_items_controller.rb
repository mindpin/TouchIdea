class VoteItemsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token, only: [:create, :praise]
  def create
    @vote = Vote.find params[:vote_id]
    @vote_item = @vote.vote_items.create vote_item_params
    render json: @vote_item.valid? ? @vote_item : @vote_item.errors
  end

  private
  def vote_item_params
    params.require(:vote_item).permit(:title)
  end
end
