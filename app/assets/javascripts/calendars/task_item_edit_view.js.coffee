# task_item_edit_view.js.coffee

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone

$ = jQuery
template = null

getTemplate = ->
  template ||= _.template($('#new_item_dialog_template').html(), null, { variable: 'model' })

class TaskItemEditView extends View
  tagName: "div"                                # creates a new div
  events: {
    "click .btn-delete": "removeItem"           # delete button event
    "click .btn-cancel": "resetItem"            # cancel button event
  }
  initialize: (options, @calendarEvent) ->
    @render()                                   # renders the dialog view
    @originalAttributes = @model.toJSON()       # saves the original item attributes to restore if event cancelled
    @model.on "change:item_type", =>            # renders the form view when an item type is selected
      @formView.render()
    @formView = new TaskItemFormView({ model: @model }) # creates a new form view with the given model
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
      params[itemType]['completed'] ||= "false"
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
              @getCalendar().fullCalendar("updateEvent", @calendarEvent)
        type: "POST"
        url: "/#{itemType}s.json"
      }
      unless @model.isNew()
        ajaxParams.url = "/#{itemType}s/#{@model.get("item.id")}.json"
        ajaxParams.data._method = "PUT"
      $.ajax(ajaxParams)
      false
  getCalendar: ->
    @calendar ||= $("#calendar")
  render: ->
    @$el.html(getTemplate()(@model)) # renders the dialog view
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
            @getCalendar().fullCalendar("removeEvents", [@calendarEvent.id])
        type: "POST"
        url: "/#{itemType}s/#{@model.get("item.id")}"
      })
  resetItem: ->
    @model.set(@originalAttributes)

# export TaskItemEditView to the global namespace
root.TaskItemEditView = TaskItemEditView