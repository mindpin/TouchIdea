class AccountController < ApplicationController
  layout "app"
  before_filter :authenticate_user!
  def index
  end
end