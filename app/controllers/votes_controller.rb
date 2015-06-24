class VotesController < ApplicationController
  layout :choose_layout
  before_filter :authenticate_user!, except: [:show_by_token]
  before_action :set_vote, only: [:edit, :destroy]

  respond_to :html
  respond_to :json, only: [:index, :hot]
  respond_to :js, only: [:new, :create]

  def index
    @votes = Vote.recent.page(params[:page]).per(10)
  end

  def hot
    @votes = Vote.hot.page(params[:page]).per(10)
    render :index
  end

  def show
    @vote = Vote.find params[:id]
    @vote_items = @vote.vote_items_rand_order_by_user current_user
  end

  # !!R
  # def new
  #   @vote = current_user.votes.new
  #   case params[:kind]
  #   when 'text'
  #     respond_with(@vote)
  #   when 'comment'
  #     render :new_with_comment
  #   when 'weburl'
  #     _new_with_weburl
  #   end
  # end

  # def _new_with_weburl
  #   return render :new_with_weburl_select_category if params[:category_id].blank?

  #   if params[:infocard_id].blank?
  #     @category = InfocardAppCategory.find(params[:category_id])
  #     return render :new_with_weburl_select_infocard
  #   end

  #   @category = InfocardAppCategory.find(params[:category_id])
  #   @infocard = Infocard.find(params[:infocard_id])
  #   render :new_with_weburl_by_infocard
  # end

  # 创建普通议题
  def new_common
    @vote = current_user.votes.new
  end

  # 创建购物点评
  def new_shopping
    @vote = current_user.votes.new
  end

  # 创建引用分享
  def new_quote
    @vote = current_user.votes.new
  end


  def created_success
    @vote = current_user.votes.find params[:id]
  end

  def edit
    if @vote.finished?
      redirect_to result_vote_path(@vote), alert: '议题已经过期'
    end
  end

  def create
    @vote = current_user.votes.new(vote_params)
    if @vote.save
      redirect_to "/votes/#{@vote.id}/created_success"
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
      vote_result = Vote.page_search(params[:q], params[:page])
      @votes = vote_result.map{|vote_info|Vote.find(vote_info["_id"])}
    else
      @votes = []
    end
    respond_to do |format|
      format.html
      format.json do 
        vote_json = @votes.map do |vote|
          {
            :id    => vote.id.to_s,
            :title => vote.title.gsub(Regexp.new(params[:q]), '<span class="key">\0</span>'),
            :voted_users_count => vote.voted_users_count,
            :vote_items_count  => vote.vote_items_count
          }
        end
        render :json => vote_json
      end
    end
  end

  def praise
    @vote = Vote.find params[:id]
    @vote_items = @vote.vote_items
    @praise_vote_items = @vote_items.find params[:vote_item_ids]
    @praise_vote_items.map{|vote_item| vote_item.praise_by current_user}
    @vote_items.where(:id.nin => params[:vote_item_ids]).map{|vote_item| vote_item.cancel_praise_by(current_user)}
    # 做改变即操作即可，出错则直接报错，无需处理
    render json: true
  end

  # 随机获取一个未投票的议题
  def lucky
    return if not request.xhr?

    vote = Vote.rand_next current_user

    if vote.present?
      session[:lucky] = vote.id.to_s
      render :json => {
        :id => vote.id.to_s
      }
    else
      render :status => 404
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
    return 'detail' if %w(new_common new_shoping new_quote).include? action_name
    return 'app'
  end
end
