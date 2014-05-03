# task_item_form_view.js.coffee

root = @
{ jQuery, _, Backbone, moment } = root
{ Model, View, Collection, DeepModel } = Backbone # puts model, view, and collection into the global namespace from Backbone

$ = jQuery
template = null

getTemplate = ->
  template ||= _.template($('#new_item_content_template').html(), null, { variable: 'model' })

class TaskItemFormView extends View
  tagName: "div"
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
    "input[name=completed]"     : "item.completed"
  }
  render: ->
    @$el.html(getTemplate()(@model)) # renders the dialog view
    @stickit() # provides 2-way binding between the view and model
    @$el.find("input.select-date").datepicker({
      onClose: (dateText, inst) =>
        input = $(inst.input)
        name = input.attr('name')
        if name == 'start_date'
          end_date = @$el.find('input[name=end_date]').datepicker('option', 'minDate', dateText)
          if end_date.val() == ''
            end_date.val(input.val())
            input.datepicker('option', 'maxDate', dateText)
        else if name == 'end_date'
          start_date = @$el.find('input[name=start_date]').datepicker('option', 'maxDate', dateText)
          if start_date.val() == ''
            start_date.val(input.val())
            input.datepicker('option', 'minDate', dateText)
    })
    do =>
      startDateInput = @$el.find('input[name=start_date]')
      endDateInput = @$el.find('input[name=end_date]')

      if startDateInput.length == 1 && endDateInput.length == 1
        if startDateInput.val() != ''
          endDateInput.datepicker('option', 'minDate', startDateInput.val())
        if endDateInput.val() != ''
          startDateInput.datepicker('option', 'maxDate', endDateInput.val())
      return

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

# export TaskItemFormView to the global namespace
root.TaskItemFormView = TaskItemFormView