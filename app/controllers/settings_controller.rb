class SettingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js, only: [:update]

  def index
    @share_invitation = current_user.get_setting('share invitation')
  end

  def update
    @setting = current_user.settings.find(params[:id])
    @setting.update(setting_params)
  end

  private
  def setting_params
    params.require(:setting).permit(:value)
  end
end
