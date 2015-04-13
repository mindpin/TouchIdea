class NotificationSettingsController < ApplicationController
  before_filter :authenticate_user!

  def update
    current_user.set_setting(params[:key], params[:value])
    render :status => 200, :text => ''
  end

end
