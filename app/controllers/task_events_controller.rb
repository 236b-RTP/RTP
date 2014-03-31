class TaskEventsController < ApplicationController

  respond_to :json

  def index
    @task_events = current_user.task_events
  end

  def show
    @task_event = TaskEvent.find(params[:id])
  end

end
