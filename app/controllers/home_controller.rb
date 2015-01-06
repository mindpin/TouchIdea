class HomeController < ApplicationController
  before_filter :authenticate_user!#, only: [:dashboard]
  def index
    if current_user
      redirect_to votes_path
    else
      redirect_to new_user_session_path
    end
  end
end
