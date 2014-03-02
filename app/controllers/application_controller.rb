class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  # returns the user session that belongs to the browser session
  def current_user_session
    return nil unless cookies.signed[:authentication_key].present?
    unless @current_user_session.present? # finds and updates the session if exists
      user_session = UserSession.authenticate(cookies.signed[:authentication_key])
      if user_session.nil?
        cookies.delete(:authentication_key)
        return nil
      end
      @current_user_session = user_session
      @current_user_session.access(request) # updates the ip, user_agent, and accessed_at
    end
    @current_user_session
  end

  helper_method :current_user_session

  # returns the logged in user
  def current_user
    current_user_session.try(:user)
  end

  helper_method :current_user
end
