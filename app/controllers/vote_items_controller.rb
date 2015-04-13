class VoteItemsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]
  def create
    @vote = Vote.find params[:vote_id]
    @vote_item = @vote.vote_items.create vote_item_params
    render json: @vote_item.valid? ? @vote_item : @vote_item.errors
  end

  def praise
    @vote_item = VoteItem.find params[:id]
    # todo 考虑怎么处理用户未登录的返回
    # 失败返回nil, 成功返回true
    render json: @vote_item.praise_by current_user
  end

  private
  def vote_item_params
    params.require(:vote_item).permit(:title)
  end
end
