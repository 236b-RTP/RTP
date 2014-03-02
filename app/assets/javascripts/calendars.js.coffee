# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = @
{ jQuery } = root

jQuery ($) ->
  return unless $(document.body).hasClass("calendars-index")

  # resizes task list when window is resized
  taskList = $(".tasks-list")
  resizeFn = ->
    height = $(window).height()
    offset = taskList.offset()
    taskList.height(height - offset.top - 16)
  $(window).on("resize", resizeFn)
  resizeFn()

  # loads calendar
  $("#calendar").fullCalendar({
    defaultView: "agendaWeek"
  })

  # show new task dialog
  newTaskDialog = $("#newTaskDialog").modal({
    backdrop: "static",
    keyboard: false,
    show: false
  })
  $("#newTaskButton").on "click", ->
    newTaskDialog.modal("show")
