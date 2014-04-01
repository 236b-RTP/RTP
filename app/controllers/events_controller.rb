class EventsController < ApplicationController

  respond_to :json

  def index
  end

  def new
  end

  def create
    @event = Event.new(event_params)
    @event.start_date = Chronic.parse("#{params[:event][:start_date]} #{params[:event][:start_time]}")
    @event.end_date = Chronic.parse("#{params[:event][:end_date]} #{params[:event][:end_time]}")

    if @event.save
      @task_event = TaskEvent.create!(user: current_user, item: @event)
    else
      respond_to do |format|
        format.json { render json: { error: true }, status: 400 }
      end
    end
  end

  def edit
  end

  def update
    @event = Event.find(params[:id])
    @event.start_date = Chronic.parse("#{params[:event][:start_date]} #{params[:event][:start_time]}")
    @event.end_date = Chronic.parse("#{params[:event][:end_date]} #{params[:event][:end_time]}")

    unless @event.update_attributes(event_params)
      respond_to do |format|
        format.json { render json: { error: true }, status: 400 }
      end
    end
  end

  def destroy
  end

  def search
  end

  private

  def event_params
    params.require(:event).permit(:title, :description)
  end
end
