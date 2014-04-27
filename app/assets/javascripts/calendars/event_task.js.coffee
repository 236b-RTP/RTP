# event_task.js.coffee

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone

$ = jQuery

# constants
MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

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
  meetsSearchCriteria: (criteria) ->
    criteria = if criteria? then criteria.toLowerCase() else ''
    return true if criteria == ''
    (@get('item.title') || '').toLowerCase().indexOf(criteria) >= 0 || (@get('item.description') || '').toLowerCase().indexOf(criteria) >= 0

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

# export EventTask, EventTasks, and EventTaskCollection to the global namespace
root.EventTask = EventTask
root.EventTaskCollection = EventTaskCollection
root.EventTasks = new EventTaskCollection()