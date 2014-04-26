# calendars.js.coffee
#= require_tree ./calendars

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone

# jQuery functions
jQuery ($) ->
  return unless $(document.body).hasClass("calendars-index") # only run on calendars page

  ###################################### Calendar Functions ########################################

  # loads main calendar
  calendar = $("#calendar").fullCalendar({        # http://arshaw.com/fullcalendar/
    defaultView: "agendaWeek"                     # week view
    timezone: "local"                             # use local timezones from local systems
    eventClick: (event) ->
      new TaskItemEditView({ model: event.model }, event)  # open edit dialog when events are clicked
    eventRender: (event, el) ->
      if event.model.isTask()
        span = $(document.createElement('span'))
        span.css('background-color', event.model.get("item.tag_color")).addClass('fc-event-tag-color')
        el.find('.fc-event-inner').append(span)
      return
  })

  # makes a "to do" task droppable into the calendar div, adding the task to "doing" and rescheduling all current tasks
  $(".calendar").droppable({
    accept: ".task-instance"
    drop: (event, ui) ->
      if confirm("Are you sure you want to add this task to your calendar?") # confirm before rescheduling
        ui.draggable.data("model").schedule(ui.draggable) # reschedule all current tasks
  })

  # loads mini-calendar
  $("#mini-calendar").datepicker({                # http://jqueryui.com/datepicker/
    onSelect: (dateText) ->
      moment = $.fullCalendar.moment(dateText)    # creates a moment object using the date selected
      calendar.fullCalendar('gotoDate', moment)   # changes the main calendar view to be the same week as the moment
  })

  # resizes task list and calendar height when window is resized
  taskList = $(".tasks-list")                     # gets the tasks-list element
  resizeFn = ->
    height = $(window).height()                   # gets the height of the browser window
    taskListOffset = taskList.offset()            # gets the coordinates of the tasks-list element
    taskList.height(height - taskListOffset.top - 16) # sets the height of the tasks-list element
    calendarOffset = calendar.offset()            # gets the coordinates of the main calendar
    calendar.fullCalendar("option", "height", height - calendarOffset.top - 16) # sets the height of the calendar
  $(window).on("resize", resizeFn)                # resize the tasks-list and calendar whenever the window is resized
  resizeFn()

  # reschedules tasks
  reschedule = ->
    if EventTasks.hasOverdueTasks()               # if there are overdue tasks, display overdue dialog
      new OverdueTaskApp()
    else
      $(this).prop("disabled", true)
      $.ajax {
        cache: false
        dataType: 'json'
        error: =>
          alert('Unable to schedule task. Please try again.')
          $(this).prop("disabled", false)
        success: =>
          loadAllTasks()
          $(this).prop("disabled", false)
        type: 'POST'
        url: "/tasks/reschedule.json"
      }

    false

  # gets all the event tasks and loads them into the EventTask collection
  loadAllTasks = ->
    $.ajax({
      cache: false
      dataType: 'json'
      error: ->
        alert("Failed to fetch calendar items. Please reload the page.")
      success: (data) ->
        EventTasks.reset(data)
      type: "GET"
      url: "/task_events.json"
    })

  ######################################### Click Events  ###########################################

  $("#new-item-button").on "click", ->
    new TaskItemEditView({ model: new EventTask() })

  $("#reschedule-button").on("click", reschedule)

  new TaskApp({ el: $("div.tasks-list") })

  loadAllTasks()
