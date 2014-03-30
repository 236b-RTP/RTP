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


  # loads calendar
  calendar = $("#calendar").fullCalendar({
    defaultView: "agendaWeek"
    timezone: "local"
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


  ## render tasks and events to calendar

  # creates a model that extends the Backbone view

  class AppView extends View
    tagName: "div" # creates a div
    template: _.template($("#new_item_dialog_template").html(), null, { variable: "model" }) # content of div
    initialize: ->
      @render()
      @model.on "change:item_type", =>
        @formView.render()
      @formView = new FormView({ model: @model })
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
    dialogTitle: ->
      if @exists() then 'Edit Item' else 'New Item'
    exists: ->
      @id?
    initialize: ->
      model = { item: Item }
      for own key, model of model
        @set(key, new model(@get(key)))
      return


  class Item extends Model
    trimmedTitle: ->
      title = @get("title")
      return title unless title.length > 13
      title.substr(0, 13) + '...'
    formattedDueDate: ->
      date = new Date(@get("due_date"))
      month = date.getMonth()
      day = date.getDate()
      "#{MONTHS[month]} #{day}"


  class EventTaskCollection extends Collection
    model: EventTask


  EventTasks = new EventTaskCollection()


  class TaskView extends View
    tagName: "div"
    template: _.template($("#task_template").html(), null, { variable: "model" })
    initialize: ->
      @$el.addClass("task-instance")
    render: ->
      @$el.html(@template(@model))
      @


  # controls when views get added or removed
  class TaskApp extends View
    el: $("div.tasks-list")
    initialize: ->
      @listenTo(EventTasks, "reset", @addAll)
    addAll: ->
      EventTasks.each(@addOne, @)
    addOne: (eventTask) ->
      if eventTask.get("item_type") == "Task"
        view = new TaskView({ model: eventTask.get("item") })
        @$el.append(view.render().el)
      else
        @addEvent(eventTask)
    addEvent: (eventTask) ->
      event = eventTask.get("item")
      calendar.fullCalendar("addEventSource", {
        events: [{
          title: event.get("title")
          start: event.get("start_time")
          end: event.get("end_time")
        }]
      })


  class FormView extends View
    tagName: "div"
    template: _.template($("#new_item_content_template").html(), null, { variable: "model" })
    bindings: {
      "input[name=item_type]"     : "item_type"
      "input[name=title]"         : "title"
      "textarea[name=description]": "description"
      "input[name=start_date]"    : "start_date"
      "input[name=start_time]"    : "start_time"
      "input[name=end_date]"      : "end_date"
      "input[name=end_time]"      : "end_time"
      "input[name=due_date]"      : "due_date"
      "input[name=due_time]"      : "due_time"
      "input[name=duration]"      : "duration"
      "input[name=priority]"      : "priority"
      "input[name=difficulty]"    : "difficulty"
      "input[name=tag_name]"      : "tag_name"
      "input[name=tag_color]"     : "tag_color"
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
    new AppView({ model: new EventTask({ tag_color: "green" }) })

    
  new TaskApp()


  # gets all the event tasks and loads them into the EventTask collection
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