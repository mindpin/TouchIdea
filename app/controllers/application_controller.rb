class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def faye_server_url
    @faye_server_url ||= "#{request.protocol + request.host_with_port + '/faye'}"
  end

  def notify_subscribers(user_ids, render_options)
    client = Faye::Client.new(faye_server_url)
    user_ids.each do |user_id|
      client.publish("/notify/#{user_id}", render_to_string(render_options))
    end
  end
end
