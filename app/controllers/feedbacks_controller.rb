class FeedbacksController < ApplicationController
  before_filter :authenticate_user!

  def create
    current_user.feedbacks.create(:content => params[:content])
    render :status => 200, :text => ""
  end
end
