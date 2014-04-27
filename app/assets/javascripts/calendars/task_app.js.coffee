# task_app.js.coffee

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone

$ = jQuery

class TaskApp extends View
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
    @listenTo(EventTasks, "change", @filter)
  getCalendar: ->
    @calendar ||= $("#calendar")
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

    @getCalendar().fullCalendar("addEventSource", {
      events: [eventTask.fullCalendarParams()]
    })
  addAllEvents: ->
    @getCalendar().fullCalendar('removeEvents')
    EventTasks.each(@addEvent, @)
  filter: ->   # populates display tasks
    activeTab = @tabs.find("li.active")
    @displayedTasks.reset EventTasks.filter (model) ->
      return false if model.isEvent()
      if activeTab.hasClass("todo")
        !model.get("item.start_date")
      else if activeTab.hasClass("doing")
        !model.isCompleted() && model.get("item.start_date")? && moment().isBefore(model.getOriginalDate("item.due_date"))
      else
        model.isCompleted()


# export TaskApp to the global namespace
root.TaskApp = TaskApp