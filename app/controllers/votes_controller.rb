class VotesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_vote, only: [:edit, :destroy]

  respond_to :html
  respond_to :js, only: [:new, :create]

  def index
    @votes = Vote.by_user(current_user).recent
    respond_with(@votes)
  end

  def show
    @vote = Vote.find params[:id]
    if @vote.finished? or @vote.answered_by?(current_user)
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
      user_ids = @vote.users.map(&:id)
      notify_subscribers user_ids, partial: 'votes/create'
      redirect_to votes_path
      #respond_with(@vote)
    else
      render :new
    end
  end

  def update
    @vote = Vote.find params[:id]
    user_ids = @vote.voted_users.map(&:id)
    @vote.update(vote_params)
    respond_with(@vote)
  end

  #def destroy
    #@vote.destroy
    #respond_with(@vote)
  #end

  def result
    @vote = Vote.find params[:id]
    @questions = @vote.questions.includes(:answers)
  end
  private
  def set_vote
    @vote = current_user.votes.find(params[:id])
  end

  def vote_params
    params.require(:vote).permit(:title, :finish_at, user_ids: [], invite_uids: [], questions_attributes: [:id, :title, answers_attributes: [:id, :title, :voter_id, :_destroy]])
  end
end
