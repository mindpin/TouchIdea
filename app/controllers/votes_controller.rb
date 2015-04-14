class VotesController < ApplicationController
  layout :choose_layout
  before_filter :authenticate_user!, except: [:show_by_token]
  before_action :set_vote, only: [:edit, :destroy]

  respond_to :html
  respond_to :json, only: [:index]
  respond_to :js, only: [:new, :create]

  def index
    @votes = Vote.recent.page(params[:page])
    respond_with(@votes)
  end

  def show
    @vote = Vote.find params[:id]
  end

  def new
    @vote = current_user.votes.new
    if params[:good].blank?
      respond_with(@vote)
    else
      render :new_with_good
    end
  end

  def edit
    if @vote.finished?
      redirect_to result_vote_path(@vote), alert: '议题已经过期'
    end
  end

  def create
    @vote = current_user.votes.new(vote_params)
    if @vote.save
      redirect_to @vote
    else
      render :new
    end
  end

  def update
    @vote = Vote.find params[:id]
    user_ids = @vote.voted_users.map(&:id)
    
    if @vote.update(vote_params) and @vote.user == current_user and @vote.shares.un_shared.any?
      redirect_to @vote.shares.un_shared.last
    else
      respond_with(@vote)
    end
  end

  #def destroy
    #@vote.destroy
    #respond_with(@vote)
  #end

  def result
    @vote = Vote.find params[:id]
    @questions = @vote.questions.includes(:answers)
  end

  def show_by_token
    @vote = Vote.where(token: params[:id]).first
    if current_user
      unless @vote.invite_uids.include?(current_user.uid)
        @vote.invite_uids << current_user.uid
        @vote.save
      end
      redirect_to @vote
    end
  end

  def search
    @votes = Vote.search(params[:q]).records
    respond_to do |format|
      format.html
      format.json { render json: @votes.as_json(only: [:_id, :title], methods: [:vote_items_count, :voted_users_count])}
    end
  end

  private
  def set_vote
    @vote = current_user.votes.find(params[:id])
  end

  def vote_params
    params.require(:vote).permit(:title, :url, vote_items_attributes: [:id, :title])
  end

  def choose_layout
    action_name == 'show' ? 'detail' : 'app'
  end
end
