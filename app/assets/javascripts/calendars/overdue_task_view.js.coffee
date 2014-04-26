# overdue_task_view.js.coffee

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone

$ = jQuery
template = null

getTemplate = ->
  template ||= _.template($('#reschedule_template').html(), null, { variable: 'model' })

class OverdueTaskView extends View
  tagName: 'tr'
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
    @model.set(@originalAttributes)
  render: ->
    @$el.html(getTemplate()(@model))
    @stickit()

    @$el.find('input.select-date').datepicker()
    @$el.find(".glyphicon-calendar").on "click", ->
      targetInput = $(@).siblings("input")
      targetInput.datepicker("show") unless targetInput.prop('disabled')
      false

    @$el.find('input[type=radio]').on('click', _.bind(@setAction, @))

    @

# export OverdueTaskView to the global namespace
root.OverdueTaskView = OverdueTaskView