class VoteItemsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token, only: [:create, :praise]
  def create
    @vote = Vote.find params[:vote_id]
    @vote_item = @vote.vote_items.new vote_item_params
    @vote_item.user = current_user
    @vote_item.is_extra = true
    @vote_item.save
    
    render :json => {
      :vote_item => {
        :id => @vote_item.id.to_s,
        :title => @vote_item.title,
        :is_extra => @vote_item.is_extra
      }
    }
  end

  private
  def vote_item_params
    params.require(:vote_item).permit(:title)
  end
end
