class UserSessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      user_session = UserSession.create(user: user)
      user_session.access(request) # updates the users session info

      cookies.permanent.signed[:authentication_key] = user_session.key

      if user.preference.present?
        redirect_to calendars_path
      else
        redirect_to new_user_preference_path(user)
      end
    else
      flash.now[:error] = "<strong>Error:</strong> Invalid Credentials.".html_safe
      render :new
    end
  end

  def destroy
    current_user_session.revoke!
    cookies.delete(:authentication_key)
    redirect_to root_path
  end
end
