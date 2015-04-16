class VotesController < ApplicationController
  layout :choose_layout
  before_filter :authenticate_user!, except: [:show_by_token]
  before_action :set_vote, only: [:edit, :destroy]

  respond_to :html
  respond_to :json, only: [:index, :hot]
  respond_to :js, only: [:new, :create]

  def index
    @votes = Vote.recent.page(params[:page]).per(10)
    respond_to do |format|
      format.html { render :index}
      format.json do 
        votes_hash = @votes.map do |vote|
          {
            :id           => vote.id.to_s,
            :title        => vote.title,
            :joiner_count => vote.voted_users_count,
            :options      => vote.vote_items.map{|vi|vi.title}
          }
        end
        render(json: votes_hash)
      end
    end
  end

  def hot
    @votes = Vote.hot.page(params[:page])
    respond_to do |format|
      format.html { render :index}
      format.json { render json: @votes }
    end
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
    if !params[:q].blank?
      @votes = Vote.page_search(params[:q], params[:page]).records
    else
      @votes = []
    end
    respond_to do |format|
      format.html
      format.json { render json: @votes.as_json(only: [:_id, :title, :voted_users_count], methods: [:vote_items_count, :praised_count])}
    end
  end

  def lucky
    @vote = Vote.rand_next current_user
    if @vote
      redirect_to @vote
    else
      flash[:error] = '没有您未投票的议题了!'
      redirect_to votes_path
    end
  end

  private
  def set_vote
    @vote = current_user.votes.find(params[:id])
  end

  def vote_params
    params.require(:vote).permit(:infocard_id, :title, :url, vote_items_attributes: [:id, :title])
  end

  def choose_layout
    action_name == 'show' ? 'detail' : 'app'
  end
end
