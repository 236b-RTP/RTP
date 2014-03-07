# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = @
{ jQuery } = root

jQuery ($) ->
  return unless $(document.body).hasClass("calendars-index")

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
  $("#newTaskButton").on "click", ->
    newTaskDialog.modal("show")

  newTaskDialog.on "show.bs.modal", ->
    newTaskDialog.find("input.select-date").datepicker()

  newTaskDialog.on "hide.bs.modal", ->
    newTaskDialog.find("input.select-date").datepicker("destroy")