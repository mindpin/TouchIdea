class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource_or_scope)
    if request.referer
      redirect_path = URI.parse(request.referer).path
      return redirect_path if redirect_path != new_user_session_path
    end
    '/'
  end
end
