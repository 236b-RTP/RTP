# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = @
{ jQuery, _, Backbone } = root
{ Model, View, Collection } = Backbone # puts model, view, and collection into the global namespace from Backbone


# constants
MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']


jQuery ($) ->
  return unless $(document.body).hasClass("calendars-index")
  TASKS = root.TASKS
  EVENTS = root.EVENTS


  # loads calendar
  calendar = $("#calendar").fullCalendar({
    defaultView: "agendaWeek"
    timezone: "local"
    events: _.map EVENTS, (value, key) ->
      {
        title: value.title
        start: value.start_time
        end: value.end_time
      }

    eventClick: (event) ->

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


  # dynamically adds the tasks to the To Do task list
  trimmedTitle = (title) ->
    return title unless title.length > 13
    title.substr(0, 13) + '...'

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

  ## render tasks and events to calendar

  # creates a model that extends the Backbone view
  class ItemView extends View
    tagName: "div"
    template: _.template($(""))

  class AppView extends View
    tagName: "div" # creates a div
    template: _.template($("#new_item_dialog_template").html(), null, { variable: "model" }) # content of div
    initialize: ->
      @render()
      @eventTask = new EventTask({ tag_color: "green" })
      @eventTask.on "change:item_type", =>
        @formView.render()
      @formView = new FormView({ model: @eventTask })
      @$el.find("div.modal-body").append(@formView.render().el) # appends the content of the form to the modal's body
      dialog = @$el.appendTo(document.body).find("#newItemDialog")
      dialog.modal({
        backdrop: "static",
        keyboard: false,
        show: true
      })

      dialog.on "hidden.bs.modal", => # remove all elements from memory
        @formView.remove()
        @remove()

      @$el.find("form").on "submit", ->
        params = {}
        itemType = $(@).find("input[name=item_type]:checked").val()
        unless itemType?
          alert("Please select an item type.")
          return false
        params[itemType] = $(@).serializeObject()

        $.ajax({
          cache: false
          data: params
          error: ->
            alert("Failed to save new item. Please try again.")
          success: ->
            window.location.reload()
          type: "POST"
          url: "/#{itemType}s"
        })

        false

    render: ->
      @$el.html(@template(@model)) # renders the dialog view
      @

  # creates the content of the new item form
  class EventTask extends Model

  class FormView extends View
    tagName: "div"
    template: _.template($("#new_item_content_template").html(), null, { variable: "model" })
    bindings: {
      "input[name=item_type]": "item_type"
      "input[name=title]": "title"
      "textarea[name=description]": "description"
      "input[name=start_date]": "start_date"
      "input[name=start_time]": "start_time"
      "input[name=end_date]": "end_date"
      "input[name=end_time]": "end_time"
      "input[name=due_date]": "due_date"
      "input[name=due_time]": "due_time"
      "input[name=duration]": "duration"
      "input[name=priority]": "priority"
      "input[name=difficulty]": "difficulty"
      "input[name=tag_name]": "tag_name"
      "input[name=tag_color]": "tag_color"
    }
    render: ->
      @$el.html(@template(@model)) # renders the dialog view
      @stickit() # provides 2-way binding between the view and model
      @$el.find("input.select-date").datepicker()
      @$el.find(".spectrum").spectrum({
        showPalette: true,
        localStorageKey: "spectrum.palette"
        showButtons: false
        palette: [
          ['black', 'white', 'blanchedalmond'],
          ['rgb(255, 128, 0);', 'hsv 100 70 50', 'lightyellow']
        ]
      })
      @$el.find(".glyphicon-calendar").on "click", ->
        $(@).siblings("input").datepicker("show")
        false
      @

  $("#new-item-button").on "click", ->
    new AppView()
