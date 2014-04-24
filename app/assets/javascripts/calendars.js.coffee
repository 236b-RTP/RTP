# calendars.js.coffee

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone


# constants
MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']


# jQuery functions
jQuery ($) ->
  return unless $(document.body).hasClass("calendars-index") # only run on calendars page

  ###################################### Calendar Functions ########################################

  # loads main calendar
  calendar = $("#calendar").fullCalendar({        # http://arshaw.com/fullcalendar/
    defaultView: "agendaWeek"                     # week view
    timezone: "local"                             # use local timezones from local systems
    eventClick: (event) ->
      new AppView({ model: event.model }, event)  # open edit dialog when events are clicked
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

  reschedule = ->
    if EventTasks.hasOverdueTasks()
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

  ######################################## Backbone Views ##########################################

  class OverdueTaskApp extends View
    tagName: "div"
    template: _.template($('#reschedule_dialog_template').html(), null, { variable: 'model' })
    initialize: ->
      @render()
      @views = []
      @submitting = false

      @listenTo(@, 'event:update', @updateSubmitButton)

      @dialog = @$el.appendTo(document.body).find(".modal")
      @dialog.modal({
        backdrop: "static",
        keyboard: false,
        show: true
      })

      @dialog.on "hidden.bs.modal", => # removes all elements from memory
        unless @submitting
          _.each(@views, ((view) ->
            view.restoreOriginalAttributes()
          ))
        @remove()

      @$el.find('form').on('submit', _.bind(@save, @))

      @overdueTable = @$el.find('table.overdue-tasks')
      @overdueTableContainer = @overdueTable.find('tbody')

      _.each(EventTasks.overdueTasks(), @addOverdueTask, @)
    addOverdueTask: (eventTask) ->
      view = new OverdueTaskView({ model: eventTask, application: @ })
      @overdueTableContainer.append(view.render().el)
      @views.push(view)
    render: ->
      @$el.html(@template(@model)) # renders the dialog view
      @
    isFinished: ->
      _.filter(@views, ((view)->
        !view.isCompleted()
      )).length == 0
    updateSubmitButton: ->
      @submitBtn ||= @$el.find('input[type=submit]')
      @submitBtn.prop('disabled', !@isFinished())
    save: ->
      return false unless @isFinished()
      return false if @submitting

      @submitting = true # only submit once, ever

      calls = []
      _.each(@views, ((view) ->
        model = view.model

        # make the ajax call and add it to an array so that we can use a jQuery promise
        # to wait for all ajax calls to finish before rescheduling
        calls.push($.ajax({
          cache: false
          data: {
            _method: 'PUT'
            task: {
              completed: model.isCompleted() ? 'true' : 'false'
              due_date: model.get('item.due_date')
              due_time: model.get('item.due_time')
            }
          }
          dataType: "json"
          type: "POST"
          url: "/tasks/#{model.get("item.id")}.json"
        }))
      ))

      # wait for all calls to finish, then reschedule
      $.when.apply($, calls).done =>
        @dialog.modal('hide')
        reschedule()

      false


  class OverdueTaskView extends View
    tagName: 'tr'
    template: _.template($('#reschedule_template').html(), null, { variable: 'model' })
    bindings: {
      "input[name=due_date]" : "item.due_date"
      "input[name=due_time]" : "item.due_time"
    }
    initialize: (options) ->
      @app = options.application
      @action = ''
      @completed = false

      @originalAttributes = @model.toJSON()

      @listenTo(@model, 'change', @setCompleted)
    isCompleted: ->
      @completed
    setAction: (event) ->
      target = $(event.target)
      @action = target.val()
      completed = @action == 'completed'

      @model.set('item.completed', completed)
      @$el.find('.form-control').prop('disabled', completed)
      @setCompleted() unless completed
    setCompleted: ->
      if @action == 'completed'
        @completed = true
      else
        @completed = moment("#{@model.get('item.due_date')} #{@model.get('item.due_time')}", "MM/DD/YYYY HH:mm").isAfter()

      @app.trigger('event:update')
    restoreOriginalAttributes: ->
      console.log('restoring')
      @model.set(@originalAttributes)
    render: ->
      @$el.html(@template(@model))
      @stickit()

      @$el.find('input.select-date').datepicker()
      @$el.find(".glyphicon-calendar").on "click", ->
        targetInput = $(@).siblings("input")
        targetInput.datepicker("show") unless targetInput.prop('disabled')
        false

      @$el.find('input[type=radio]').on('click', _.bind(@setAction, @))

      @

  # new item dialog Backbone view
  class AppView extends View
    tagName: "div"                                # creates a new div
    template: _.template($("#new_item_dialog_template").html(), null, { variable: "model" }) # content of new div

    events: {
      "click .btn-delete": "removeItem"           # delete button event
      "click .btn-cancel": "resetItem"            # cancel button event
    }

    initialize: (options, @calendarEvent) ->
      @render()                                   # renders the dialog view
      @originalAttributes = @model.toJSON()       # saves the original item attributes to restore if event cancelled
      @model.on "change:item_type", =>            # renders the form view when an item type is selected
        @formView.render()
      @formView = new FormView({ model: @model }) # creates a new form view with the given model
      @$el.find("div.modal-body").append(@formView.render().el) # appends the content of the form to the modal's body
      dialog = @$el.appendTo(document.body).find("#newItemDialog")
      dialog.modal({
        backdrop: "static",
        keyboard: false,
        show: true
      })
      dialog.on "hidden.bs.modal", =>             # removes all elements from memory
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
          ui.helper.width($(@).width()).css("border", "1.5px solid black")
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
      if eventTask.isTask()
        view = new TaskView({ model: eventTask })
        index = @displayedTasks.indexOf(eventTask)
        previous = @displayedTasks.at(index - 1)
        previousView = previous && previous.view
        if index == 0 || !previous || !previousView
          @$el.append(view.render().el)
        else
          previousView.$el.before(view.render().el)
    addEvent: (eventTask) ->
      return unless eventTask.get("item.start_date")?
      return if eventTask.isCompleted()

      calendar.fullCalendar("addEventSource", {
        events: [eventTask.fullCalendarParams()]
      })
    addAllEvents: ->
      calendar.fullCalendar('removeEvents')
      EventTasks.each(@addEvent, @)
    filter: ->   # populates display tasks
      activeTab = @tabs.find("li.active")
      @displayedTasks.reset EventTasks.filter (model) ->
        return false if model.isEvent()
        if activeTab.hasClass("todo")
          !model.get("item.start_date")
        else if activeTab.hasClass("doing")
          model.get("item.start_date")? && moment().isBefore(model.getOriginalDate("item.due_date"))
        else
          model.isCompleted()


  # new item form view
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
      _renderItem = (ul, item) ->
        $("<li>")
          .append($("<div>").addClass("pull-right color-indicator").css("background-color", item.color))
          .append($("<a>").text(item.label))
          .appendTo(ul)
      autocomplete = @$el.find("input.tag_name").autocomplete({
        minLength: 1
        source: "/task_events/tags.json"
        select: (event, ui) =>
          @$el.find(".spectrum").spectrum("set", ui.item.color)
      })
      autocomplete.data("uiAutocomplete")._renderItem = _renderItem if autocomplete.length == 1
      @


  ##################################### Backbone DeepModels ########################################


  # creates the content of the new item form
  class EventTask extends DeepModel
    defaults: {
      item: { tag_color: "orange" }
    }
    initialize: ->
      @updateDates()
    isTask: ->
      @get('item_type') == 'Task'
    isEvent: ->
      @get('item_type') == 'Event'
    isCompleted: ->
      @get('item.completed') == true || @get('item.completed') == 'true'
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
        className: @className()
      }
    dueDateColor: ->
      if moment(@getOriginalDate("item.due_date")).isBefore(moment().add("days", 1))
        "#a70304"
      else if moment(@getOriginalDate("item.due_date")).isBefore(moment().add("days", 2))
        "#da8005"
      else
        "#02ae4c"
    schedule: (view) ->
      view.hide()
      $.ajax {
        cache: false
        dataType: 'json'
        error: ->
          alert('Unable to schedule task. Please try again.')
        success: ->
          loadAllTasks()
        type: 'POST'
        url: "/tasks/#{@get("item.id")}/schedule"
      }
    className: ->
      "fc-taskevent-#{@get("item_type").toLowerCase()}"


  ##################################### Backbone Collections #######################################


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
    overdueTasks: ->
      @filter((eventTask) ->
        eventTask.isTask() && !eventTask.isCompleted() && moment(eventTask.get('item.due_date')).isBefore()
      )
    hasOverdueTasks: ->
      @overdueTasks().length > 0

  EventTasks = new EventTaskCollection()

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
  loadAllTasks()

  ######################################### Click Events  ###########################################


  $("#new-item-button").on "click", ->
    new AppView({ model: new EventTask() })

  $("#reschedule-button").on("click", reschedule)


  new TaskApp()
