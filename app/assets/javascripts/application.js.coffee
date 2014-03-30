# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery-ui/jquery-ui
#= require jquery_ujs
# require turbolinks
#= require bootstrap
#= require moment-with-langs
#= require fullcalendar/fullcalendar
#= require spectrum
#= require underscore
#= require backbone
#= require backbone-stickit
#= require backbone-deep-model
#= require_self
#= require_tree .

root = this

{ _, jQuery } = root

# allows use of backbone without erb confusion
_.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
}

# creates a jQuery plugin that turns a form into a javascript object
jQuery.fn.serializeObject = ->
  obj = {}
  arr = @serializeArray()
  for element in arr
    if obj[element.name] != undefined
      unless jQuery.isArray(obj[element.name])
        obj[element.name] = [obj[element.name]]
      obj[element.name].push(element.value || "")
    else
      obj[element.name] = element.value || ""
  obj

