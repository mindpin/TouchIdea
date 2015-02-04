class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  #def method_missing(provider)
  def weibo
    provider = :weibo
    if !User.omniauth_providers.index(provider).nil?
      #omniauth = request.env["omniauth.auth"]
      omniauth = env["omniauth.auth"]

      if current_user #or User.find_by_email(auth.recursive_find_by_key("email"))
        current_user.user_tokens.find_or_create_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
        flash[:notice] = "Authentication successful"
        redirect_to edit_user_registration_path
      else

        authentication = UserToken.where(provider: omniauth['provider'], uid: omniauth['uid']).first

        if authentication
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider']
          #sign_in_and_redirect(:user, authentication.user)
          #sign_in_and_redirect(authentication.user, :event => :authentication)
          authentication.user.update_attribute :avatar_url, omniauth.extra.try(:raw_info).try(:avatar_hd) if omniauth.extra.try(:raw_info).try(:avatar_hd)
          sign_in_and_redirect(authentication.user)
        else

          #create a new user
          unless omniauth.uid.blank?
            user = User.where(uid: omniauth.uid).first
            user ||= User.new(:uid => omniauth.uid, :nickname => omniauth.info.nickname)
            user.avatar_url = omniauth.extra.try(:raw_info).try(:avatar_hd)
          else
            user = User.new
          end

          user_token = user.apply_omniauth(omniauth)
          #user.confirm! #unless user.email.blank?

          if user.save
            user_token.save
            flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider'] 
            sign_in_and_redirect(:user, user)
          else
            session[:omniauth] = omniauth.except('extra')
            redirect_to new_user_registration_url
          end
        end
      end
    end
  end
end
