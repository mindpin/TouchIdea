class NotificationsController < ApplicationController
  layout 'app'
  respond_to :html
  respond_to :json

  def index
    @notifications = current_user.notifies
      .recent
      .page(params[:page]).per(20)
    respond_with(@notifications)
  end
end
