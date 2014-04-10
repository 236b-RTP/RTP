class TaskEventsController < ApplicationController

  respond_to :json

  def index
    @task_events = current_user.task_events
  end

  def show
    @task_event = TaskEvent.find(params[:id])
  end

  def tags
    tasks = current_user.tasks.where('tag_name ILIKE ?', "#{params[:term]}%")
    @tags = tasks.inject({}) do |memo, task|
      memo[task.tag_name] ||= []
      memo[task.tag_name].push(task.tag_color) unless memo[task.tag_name].include?(task.tag_color)
      memo
    end
  end

end
