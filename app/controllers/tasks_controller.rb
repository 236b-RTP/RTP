class TasksController < ApplicationController

  respond_to :json

  def index
  end

  def new
  end

  def create
    @task = Task.new(task_params)
    @task.due_date = Chronic.parse("#{params[:task][:due_date]} #{params[:task][:due_time]}")

    if @task.save
      @task_event = TaskEvent.create!(user: current_user, item: @task)
      @task_event
    else
      respond_to do |format|
        format.json { render json: { error: true }, status: 400 }
      end
    end
  end

  def edit
  end

  def update
    @task = Task.find(params[:id])
    @task.due_date = Chronic.parse("#{params[:task][:due_date]} #{params[:task][:due_time]}")

    unless @task.update_attributes(task_params)
      respond_to do |format|
        format.json { render json: { error: true }, status: 400 }
      end
    end
  end

  def destroy
    task = Task.find(params[:id])
    task.task_event.destroy
    task.destroy
    respond_to do |format|
      format.json { render json: { error: false } }
    end
  end

  def search
  end

  def schedule
    task = Task.find(params[:id])
    task.schedule!

    respond_to do |format|
      format.json { render json: { error: false } }
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :tag_name, :tag_color, :priority, :difficulty, :duration)
  end
end
