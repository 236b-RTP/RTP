class PreferencesController < ApplicationController

  def show
  end

  def new
    @user = User.find(params[:user_id])
    @preference = @user.build_preference
  end

  def create
    @user = User.find(params[:user_id])
    @preference = @user.build_preference(new_preferences_params)
    if @preference.save
      redirect_to calendars_path
    else
      flash.now[:error] = "<ol><li>#{@preference.errors.full_messages.join('</li><li>')}</li></ol>".html_safe
      render :new
    end
  end

  def edit
  end

  def update
  end

  private

  def new_preferences_params
    params.require(:preference).permit(:profile_type, :start_time, :end_time)
  end
end
