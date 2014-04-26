# task_view.js.coffee

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone

$ = jQuery
template = null

getTemplate = ->
  template ||= _.template($('#task_template').html(), null, { variable: 'model' })

class TaskView extends View
  tagName: "div"
  events: {
    "click": "edit"
  }
  initialize: ->
    @$el.addClass("task-instance")
    unless @model.get("item.start_date")
      @$el.draggable({
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
    @$el.html(getTemplate()(@model))
    @
  edit: ->
    new TaskItemEditView({ model: @model })

# export TaskView to the global namespace
root.TaskView = TaskView