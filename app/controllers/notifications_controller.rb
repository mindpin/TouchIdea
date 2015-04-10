class NotificationsController < ApplicationController
  layout 'app'

  def index
    @notifications = current_user.notifies
  end
end
