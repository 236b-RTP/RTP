# overdue_task_app.js.coffee

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone

$ = jQuery
template = null

getTemplate = ->
  template ||= _.template($('#reschedule_dialog_template').html(), null, { variable: 'model' })

class OverdueTaskApp extends View
  tagName: "div"
  initialize: (options) ->
    @render()
    @views = []
    @submitting = false
    @callback = options.callback

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
    @$el.html(getTemplate()(@model)) # renders the dialog view
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
      @callback.call(@)

    false

# export OverdueTaskApp to the global namespace
root.OverdueTaskApp = OverdueTaskApp