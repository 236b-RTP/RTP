class EventsController < ApplicationController
  def index
  end

  def new
  end

  def create
    @event = Event.new(task_params)

    if @event.save
      flash[:success] = "Your event has been created."
      redirect_to calendars_path
    else
      flash.now[:error] = "<ol><li>#{@event.errors.full_messages.join('</li><li>')}</li></ol>".html_safe
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

  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time)
  end
end
