require 'pry'

class TasksController < ApplicationController
  def index
  end

  def new
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      flash[:success] = "Your task has been created."
      puts "********************************************************TASK SAVED"
    else
      flash.now[:error] = "<ol><li>#{@task.errors.full_messages.join('</li><li>')}</li></ol>".html_safe
      render :new
      puts "*****************************************************TASK SAVED RETURNS FALSE"
    end
  end

  def task_params
     params.require(:task).permit(:title, :start_time,  :end_date, :event_details)
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def search
  end
end
