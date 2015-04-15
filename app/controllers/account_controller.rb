class AccountController < ApplicationController
  layout :set_layout
  before_filter :authenticate_user!
  def index
  end

  def created_votes
    @created_votes = current_user.votes.page(params[:page])
  end

  def joined_votes
    @joined_votes = current_user.voted_votes.page(params[:page])
  end

  def notification_setting
  end

  def feedback
  end

  def about
  end

  def info
  end

  private
  def set_layout
    case action_name
    when "index" then "app"
    when "created_votes", "joined_votes", "notification_setting", "feedback", 'about', 'info'
      "detail"
    end
  end
end