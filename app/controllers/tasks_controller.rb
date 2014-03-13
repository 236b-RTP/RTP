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
    else
      flash.now[:error] = "<ol><li>#{@task.errors.full_messages.join('</li><li>')}</li></ol>".html_safe
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def search
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :tag, :priority, :difficulty)
  end
end
