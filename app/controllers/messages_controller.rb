class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_message, only: [:edit, :destroy]

  respond_to :html

  def index
    @messages = current_user.notifies.recent.page params[:page]
    respond_with(@messages)
    @messages.each(&:read!)
  end
end

