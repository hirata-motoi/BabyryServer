if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->

$ ->
  $('.login').on 'click', () ->
    $('#top_choice').hide()
    $('#top_login').show()
    $('#top_register').hide()
    window.console.log location.href

  $('.register').on 'click', () ->
    $('#top_choice').hide()
    $('#top_login').hide()
    $('#top_register').show()
