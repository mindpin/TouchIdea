class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  #def method_missing(provider)
  def weibo
    provider = :weibo
    if !User.omniauth_providers.index(provider).nil?
      #omniauth = request.env["omniauth.auth"]
      omniauth = env["omniauth.auth"]

      if current_user #or User.find_by_email(auth.recursive_find_by_key("email"))
        authentication = current_user.user_tokens.where(provitder: omniauth['provider']).last
        authentication = current_user.user_tokens.where(provider: omniauth['provider'], uid: omniauth['uid']).first_or_create unless authentication
        authentication.update_attributes({token: omniauth['credentials']['token'], expires_at: omniauth['credentials']['expires_at']}) unless omniauth['credentials'].blank?
        redirect_to after_sign_in_path_for(authentication.user)
      else

        authentication = UserToken.where(provider: omniauth['provider'], uid: omniauth['uid']).first

        if authentication
          flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth['provider']
          #sign_in_and_redirect(:user, authentication.user)
          #sign_in_and_redirect(authentication.user, :event => :authentication)
          authentication.update_attributes({token: omniauth['credentials']['token'], expires_at: omniauth['credentials']['expires_at']}) unless omniauth['credentials'].blank?

          if omniauth.extra.try(:raw_info)
            authentication.user.update_attributes(
              :avatar_url    => omniauth.extra.try(:raw_info).try(:avatar_hd),
              :location      => omniauth.extra.try(:raw_info).try(:location),
              :gender        => omniauth.extra.try(:raw_info).try(:gender),
              :description   => omniauth.extra.try(:raw_info).try(:description)
            )
          end
          sign_in_and_redirect(authentication.user)
        else

          #create a new user
          unless omniauth.uid.blank?
            user = User.where(uid: omniauth.uid).first
            user ||= User.new(:uid => omniauth.uid, :nickname => omniauth.info.nickname)
            user.avatar_url = omniauth.extra.try(:raw_info).try(:avatar_hd)
            user.location   = omniauth.extra.try(:raw_info).try(:location)
            user.gender     = omniauth.extra.try(:raw_info).try(:gender)
            user.description  = omniauth.extra.try(:raw_info).try(:description)

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
