# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone


# constants
MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']


jQuery ($) ->
  return unless $(document.body).hasClass("calendars-index")


  # loads calendar
  calendar = $("#calendar").fullCalendar({
    defaultView: "agendaWeek"
    timezone: "local"
    eventClick: (event) ->
      new AppView({ model: event.model }, event)
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
    events: {
      "click .btn-delete": "removeItem"
      "click .btn-cancel": "resetItem"
    }
    initialize: (options, @calendarEvent) ->
      @render()
      @originalAttributes = @model.toJSON()
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

      form = @$el.find("form").on "submit", =>
        params = {}
        itemType = @model.get("item_type")
        unless itemType?
          alert("Please select an item type.")
          return false
        itemType = itemType.toLowerCase()
        params[itemType] = form.serializeObject()

        ajaxParams = {
          cache: false
          data: params
          dataType: "json"
          error: ->
            alert("Failed to save new item. Please try again.")
          success: (data) =>
            dialog.modal("hide")
            if @model.isNew()
              EventTasks.add(new EventTask(data))
            else
              @model.set(data)
              @model.updateDates()
              if @calendarEvent?
                _.extend(@calendarEvent, @model.fullCalendarParams())
                calendar.fullCalendar("updateEvent", @calendarEvent)
          type: "POST"
          url: "/#{itemType}s.json"
        }

        unless @model.isNew()
          ajaxParams.url = "/#{itemType}s/#{@model.get("item.id")}.json"
          ajaxParams.data._method = "PUT"

        $.ajax(ajaxParams)

        false

    render: ->
      @$el.html(@template(@model)) # renders the dialog view
      @

    removeItem: ->
      if confirm("Are you sure you want to delete this item?")
        itemType = @model.get("item_type").toLowerCase()
        $.ajax({
          cache: false
          dataType: "json"
          data: {
            _method: "DELETE"
          }
          error: ->
            alert("Unable to delete item. Please try again.")
          success: =>
            @$el.find("#newItemDialog").modal("hide")
            EventTasks.remove(@model)
            if @calendarEvent?
              calendar.fullCalendar("removeEvents", [@calendarEvent.id])
          type: "POST"
          url: "/#{itemType}s/#{@model.get("item.id")}"
        })

    resetItem: ->
      @model.set(@originalAttributes)


  # creates the content of the new item form
  class EventTask extends DeepModel
    defaults: {
      item: { tag_color: "orange" }
    }
    initialize: ->
      @updateDates()
    getOriginalDate: (attribute) ->
      @originalDates[attribute]
    updateDates: ->
      @originalDates = {}
      types = ["due", "start", "end"]
      for type in types
        if @get("item.#{type}_date")?
          @originalDates["item.#{type}_date"] = @get("item.#{type}_date")
          date = moment(@get("item.#{type}_date"))
          @set("item.#{type}_date", date.format("MM/DD/YYYY"))
          @set("item.#{type}_time", date.format("HH:mm"))
    dialogTitle: ->
      if @isNew() then 'New Item' else 'Edit Item'
    trimmedTitle: ->
      title = @get("item.title")
      return title unless title.length > 13
      title.substr(0, 13) + '...'
    formattedDueDate: ->
      date = new Date(@get("item.due_date"))
      month = date.getMonth()
      day = date.getDate()
      "#{MONTHS[month]} #{day}"
    fullCalendarParams: ->
      {
        title: @get("item.title")
        start: jQuery.fullCalendar.moment(@getOriginalDate("item.start_date"))
        end: jQuery.fullCalendar.moment(@getOriginalDate("item.end_date"))
        model: @
        id: @get("item.id")
      }
    dueDateColor: ->
      if moment(@getOriginalDate("item.due_date")).isBefore(moment().add("days", 1))
        "#a70304"
      else if moment(@getOriginalDate("item.due_date")).isBefore(moment().add("days", 2))
        "#da8005"
      else
        "#02ae4c"
    schedule: ->
      console.log("I am scheduled")



  class EventTaskCollection extends Collection
    model: EventTask
    comparator: (taskA, taskB) ->
      taskAType = taskA.get("item_type")
      taskBType = taskB.get("item_type")
      if taskAType == "Event" && taskBType == "Task"
        return -1
      else if taskAType == "Task" && taskBType == "Event"
        return 1
      else if taskAType == "Event" && taskBType == "Event"
        return 0
      else
        taskADue = taskA.getOriginalDate("item.due_date")
        taskBDue = taskB.getOriginalDate("item.due_date")
        if moment(taskADue).isBefore(taskBDue)
          return -1
        else if moment(taskADue).isAfter(taskBDue)
          return 1
        else
          return 0


  EventTasks = new EventTaskCollection()


  class TaskView extends View
    tagName: "div"
    template: _.template($("#task_template").html(), null, { variable: "model" })
    events: {
      "click": "edit"
    }
    initialize: ->
      @$el.addClass("task-instance").draggable({
        revert: "invalid"
        helper: "clone"
        appendTo: "body"
        zIndex: 9999
        start: (event, ui) ->
          $(@).addClass("invisible")
          ui.helper.width($(@).width()).css("border", "2px solid black")
        stop: ->
          $(@).removeClass("invisible")
      })
      @$el.data("model", @model)
      @listenTo(@model, "remove", @remove)
      @listenTo(@model, "change", @render)
    render: ->
      @$el.html(@template(@model))
      @
    edit: ->
      new AppView({ model: @model })


  # controls when views get added or removed
  class TaskApp extends View
    el: $("div.tasks-list")
    initialize: ->
      @displayedTasks = new EventTaskCollection()
      @tabs = $("ul.tasks-tabs")
      @tabs.on "click", "a", (event) =>
        target = $(event.target).closest("li")
        return false if target.hasClass("active")
        @tabs.find("li.active").removeClass("active")
        target.addClass("active")
        @filter()
        false
      @listenTo(@displayedTasks, "reset", @addAll)
      @listenTo(@displayedTasks, "add", @addOne)
      @listenTo(EventTasks, "add reset", @filter)
      @listenTo(EventTasks, "add", @addEvent)
      @listenTo(EventTasks, "reset", @addAllEvents)
    addAll: ->
      @$el.empty()
      @displayedTasks.each(@addOne, @)
    addOne: (eventTask) ->
      if eventTask.get("item_type") == "Task"
        view = new TaskView({ model: eventTask })
        index = @displayedTasks.indexOf(eventTask)
        previous = @displayedTasks.at(index - 1)
        previousView = previous && previous.view
        if index == 0 || !previous || !previousView
          @$el.append(view.render().el)
        else
          previousView.$el.before(view.render().el)
    addEvent: (eventTask) ->
      return unless eventTask.get("item_type") == "Event"
      calendar.fullCalendar("addEventSource", {
        events: [eventTask.fullCalendarParams()]
      })
    addAllEvents: ->
      EventTasks.each(@addEvent, @)
    filter: ->   # populates display tasks
      activeTab = @tabs.find("li.active")
      @displayedTasks.reset EventTasks.filter (model) ->
        return false if model.get("item_type") == "Event"
        if activeTab.hasClass("todo")
          !model.get("item.start_date")
        else if activeTab.hasClass("doing")
          model.get("item.start_date")? && moment(model.getOriginalDate("item.end_date")).isBefore(moment())
        else
          false




  class FormView extends View
    tagName: "div"
    template: _.template($("#new_item_content_template").html(), null, { variable: "model" })
    bindings: {
      "input[name=item_type]"     : "item_type"
      "input[name=title]"         : "item.title"
      "textarea[name=description]": "item.description"
      "input[name=start_date]"    : "item.start_date"
      "input[name=start_time]"    : "item.start_time"
      "input[name=end_date]"      : "item.end_date"
      "input[name=end_time]"      : "item.end_time"
      "input[name=due_date]"      : "item.due_date"
      "input[name=due_time]"      : "item.due_time"
      "input[name=duration]"      : "item.duration"
      "input[name=priority]"      : "item.priority"
      "input[name=difficulty]"    : "item.difficulty"
      "input[name=tag_name]"      : "item.tag_name"
      "input[name=tag_color]"     : "item.tag_color"
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
    new AppView({ model: new EventTask() })

  $(".calendar").droppable({
    accept: ".task-instance"
    drop: (event, ui) ->
      if confirm("Are you sure you want to add this task to your calendar?")
        ui.draggable.data("model").schedule()
  })

    
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