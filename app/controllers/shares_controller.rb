class SharesController < ApplicationController
  before_filter :authenticate_user!

  def show
    @token = current_user.user_tokens.last
    if @token.expired?
      @client = WeiboOAuth2::Client.new
      @client.get_token_from_hash({:access_token=> @token.token,:expires_at=> @token.expires_at})
      flash[:error] = '微博信息过期，请重新登录，以便邀请好友'
      sign_out(current_user)
      redirect_to new_user_session_path
      #redirect_to '/users/auth/weibo'
    else
      redirect_to weibo_share_path(params[:id])
    end
  end

  def weibo
    @share = Share.find params[:id]
    if @share.share!
      redirect_to votes_path, notice: '成功将邀请信息分享到微博！' 
    else
      redirect_to votes_path, error: '邀请信息分享失败' 
    end
  end
end
