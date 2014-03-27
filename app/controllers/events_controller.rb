class EventsController < ApplicationController
  def index
  end

  def new
  end

  def create
    @event = Event.new(event_params)
    @event.start_time = Chronic.parse("#{params[:event][:start_date]} #{params[:event][:start_time]}")
    @event.end_time = Chronic.parse("#{params[:event][:end_date]} #{params[:event][:end_time]}")

    if @event.save
      task_event = TaskEvent.create!(user: current_user, item: @event)
      respond_to do |format|
        format.html { redirect_to calendars_path }
        format.json { render json: task_event }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:error] = "<ol><li>#{@event.errors.full_messages.join('</li><li>')}</li></ol>".html_safe
          render :new
        end
        format.json { render json: { error: true }, status: 400 }
      end
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
    params.require(:event).permit(:title, :description)
  end
end
