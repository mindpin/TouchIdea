class VoteItemsController < ApplicationController
  def praise
    @vote_item = VoteItem.find params[:id]
    # todo 考虑怎么处理用户未登录的返回
    # 失败返回nil, 成功返回true
    render json: @vote_item.praise_by current_user
  end
end
