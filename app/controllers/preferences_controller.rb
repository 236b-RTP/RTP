class PreferencesController < ApplicationController

  def show
  end

  def new
    @user = User.find(params[:user_id])
    @preference = @user.build_preference
  end

  def create
    @user = User.find(params[:user_id])
    @preference = @user.build_preference(preferences_params)
    if @preference.save
      redirect_to calendars_path
    else
      flash.now[:error] = "<ol><li>#{@preference.errors.full_messages.join('</li><li>')}</li></ol>".html_safe
      render :new
    end
  end

  def edit
    @user = current_user
    @preference = @user.preference
  end

  def update
    @user = current_user
    @preference = @user.preference
    if @preference.update_attributes(preferences_params)
      Task.reschedule!(current_user)
      redirect_to calendars_path
    else
      flash.now[:error] = "<ol><li>#{@preference.errors.full_messages.join('</li><li>')}</li></ol>".html_safe
      render :edit
    end
  end

  private

  def preferences_params
    params.require(:preference).permit(:profile_type, :start_time, :end_time, :schedule_spread)
  end
end
