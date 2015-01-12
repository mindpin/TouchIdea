class VotesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_vote, only: [:show, :edit, :update, :destroy, :result]

  respond_to :html
  respond_to :js, only: [:new]

  def index
    @votes = Vote.by_user(current_user).recent
    respond_with(@votes)
  end

  def show
    if @vote.answered_by? current_user
      redirect_to result_vote_path(@vote)
    else
      @vote.questions.each{|q| q.answers.new}
      respond_with(@vote)
    end
  end

  def new
    if params[:vote]
      @vote = current_user.votes.new vote_params
    else
      @vote = current_user.votes.new
    end
    @vote.questions.build
    respond_with(@vote)
  end

  #def edit
  #end

  def create
    @vote = current_user.votes.new(vote_params)
    if @vote.save
      redirect_to votes_path
      #respond_with(@vote)
    else
      render :new
    end
  end

  def update
    @vote.update(vote_params)
    respond_with(@vote)
  end

  #def destroy
    #@vote.destroy
    #respond_with(@vote)
  #end

  def result
    
  end
  private
  def set_vote
    @vote = current_user.votes.find(params[:id])
  end

  def vote_params
    params.require(:vote).permit(:title, :finish_at, user_ids: [], invite_uids: [], questions_attributes: [:id, :title, answers_attributes: [:id, :title, :voter_id, :_destroy]])
  end
end

