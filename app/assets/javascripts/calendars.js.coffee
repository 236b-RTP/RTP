# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = @
{ jQuery } = root


# constants
MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']


jQuery ($) ->
  return unless $(document.body).hasClass("calendars-index")
  TASKS = root.TASKS


  # loads calendar
  calendar = $("#calendar").fullCalendar({
    defaultView: "agendaWeek"
  })


  # loads mini-calendar
  $("#mini-calendar").datepicker({
    onSelect: (dateText) ->
      mom = $.fullCalendar.moment(dateText)
      calendar.fullCalendar('gotoDate', mom)
  })


  # resizes task list and calendar height when window is resized
  taskList = $(".tasks-list")
  resizeFn = ->
    height = $(window).height()
    taskListOffset = taskList.offset()
    taskList.height(height - taskListOffset.top - 16)
    calendarOffset = calendar.offset()
    calendar.fullCalendar("option", "height", height - calendarOffset.top - 16)
  $(window).on("resize", resizeFn)
  resizeFn()


  # show new task dialog
  newTaskDialog = $("#newTaskDialog").modal({
    backdrop: "static",
    keyboard: false,
    show: false
  })
  $("#new-task-button").on "click", ->
    newTaskDialog.modal("show")

  newTaskDialog.on "show.bs.modal", ->
    newTaskDialog.find("input.select-date").datepicker()
    $(".basic").spectrum();

  newTaskDialog.on "hide.bs.modal", ->
    newTaskDialog.find("input.select-date").datepicker("destroy")


  # show new event dialog
  newEventDialog = $("#newEventDialog").modal({
    backdrop: "static",
    keyboard: false,
    show: false
  })
  $("#new-event-button").on "click", ->
    newEventDialog.modal("show")

  newEventDialog.on "show.bs.modal", ->
    newEventDialog.find("input.select-date").datepicker()
    $(".basic").spectrum();

  newEventDialog.on "hide.bs.modal", ->
    newEventDialog.find("input.select-date").datepicker("destroy")


  # dynamically adds the tasks to the To Do task list
  trimmedTitle = (title) ->
    return title unless title.length > 25
    title.substr(0, 25) + '...'

  formattedDate = (date) ->
    date = new Date(date)
    month = date.getMonth()
    day = date.getDate()
    "#{MONTHS[month]} #{day}"

  $.each TASKS, (index, task) ->
    taskEl = $(document.createElement('div')).addClass('task-instance')
    taskEl.append(
      $(document.createElement('div')).addClass('task-tag-color').css('background-color', task.tag_color)
    )
    taskEl.append(
      $(document.createElement('div')).addClass('task-name').append(document.createTextNode(trimmedTitle(task.title)))
    )
    taskEl.append(
      $(document.createElement('div')).addClass('task-due-date').append(document.createTextNode(formattedDate(task.due_date)))
    )
    taskList.append(taskEl)

  # render tasks and events to calendar
