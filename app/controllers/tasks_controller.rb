class TasksController < ApplicationController
  def index
  end

  def new
  end

  def create
    @task = Task.new(task_params)
    @task.due_date = Chronic.parse("#{params[:task][:due_date]} #{params[:task][:due_time]}")

    if @task.save
      TaskEvent.create!(user: current_user, item: @task)
      flash[:success] = "Your task has been created."
      redirect_to calendars_path
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
    params.require(:task).permit(:title, :description, :tag_name, :tag_color, :priority, :difficulty, :duration)
  end
end
