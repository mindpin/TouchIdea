class VotesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_vote, only: [:show, :edit, :update, :destroy]

  respond_to :html
  respond_to :js, only: [:new]

  def index
    @votes = current_user.votes
    respond_with(@votes)
  end

  def show
    respond_with(@vote)
  end

  def new
    if params[:vote]
      @vote = current_user.votes.new vote_params
    else
      @vote = current_user.votes.new
    end
    respond_with(@vote)
  end

  def edit
  end

  def create
    @vote = current_user.votes.new(vote_params)
    if @vote.save
      respond_with(@vote)
    else
      render :new
    end
  end

  def update
    @vote.update(vote_params)
    respond_with(@vote)
  end

  def destroy
    @vote.destroy
    respond_with(@vote)
  end

  private
  def set_vote
    @vote = current_user.votes.find(params[:id])
  end

  def vote_params
    params.require(:vote).permit(:title, :finish_at, user_ids: [])
  end
end

