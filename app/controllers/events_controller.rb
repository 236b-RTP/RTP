class EventsController < ApplicationController
  include UserTimeZone

  respond_to :json

  def index
  end

  def new
  end

  def create
    @event = Event.new(event_params)
    with_user_time_zone do
      @event.start_date = Chronic.parse("#{params[:event][:start_date]} #{params[:event][:start_time]}")
      @event.end_date = Chronic.parse("#{params[:event][:end_date]} #{params[:event][:end_time]}")
    end

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
    with_user_time_zone do
      @event.start_date = Chronic.parse("#{params[:event][:start_date]} #{params[:event][:start_time]}")
      @event.end_date = Chronic.parse("#{params[:event][:end_date]} #{params[:event][:end_time]}")
    end

    unless @event.update_attributes(event_params)
      respond_to do |format|
        format.json { render json: { error: true }, status: 400 }
      end
    end
  end

  def destroy
    event = Event.find(params[:id])
    event.task_event.destroy
    event.destroy
    respond_to do |format|
      format.json { render json: { error: false } }
    end
  end

  def search
  end

  private

  def event_params
    params.require(:event).permit(:title, :description)
  end
end
