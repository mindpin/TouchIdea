class HomeController < ApplicationController
  before_filter :authenticate_user!
  def index
    # 登录后直接跳转到随机议题页面
    redirect_to lucky_votes_path
  end
end