class VoteItemsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token, only: [:create, :praise]
  def create
    @vote = Vote.find params[:vote_id]
    @vote_item = @vote.vote_items.create vote_item_params
    render json: @vote_item.valid? ? @vote_item : @vote_item.errors
  end

  def praise
    @vote = Vote.find params[:vote_id]
    @vote_items = @vote.vote_items
    @praise_vote_items = @vote_items.find params[:ids]
    @praise_vote_items.map{|vote_item| vote_item.praise_by current_user}
    @vote_items.where(:id.nin => params[:ids]).map{|vote_item| vote_item.cancel_praise_by(current_user)}
    # 做改变即操作即可，出错则直接报错，无需处理
    render json: true
  end

  private
  def vote_item_params
    params.require(:vote_item).permit(:title)
  end
end
