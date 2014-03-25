class CalendarsController < ApplicationController
  before_action :signin_required
  before_action :user_preferences_required

  def index
    @task = Task.new
    @tasks = current_user.tasks
    @event = Event.new
    @events = current_user.events
  end

  def preferences
  end

  def update_preferences
  end

  def add_task
  end

  private

  #
  def user_preferences_required
    redirect_to(new_user_preference_path(current_user)) unless current_user.preference.present?
  end


end
