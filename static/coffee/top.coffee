if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->

$ ->
  $('.login').on 'click', () ->
    $('#top_choice').hide()
    $('#top_login').show()
    $('#top_register').hide()
    $('#top_activate').hide()
    $('#top_password_forget').hide()
    $('#top_password_change').hide()

  $('.register').on 'click', () ->
    $('#top_choice').hide()
    $('#top_login').hide()
    $('#top_register').show()
    $('#top_activate').hide()
    $('#top_password_forget').hide()
    $('#top_password_change').hide()

  $('.logout').on 'click', () ->
    location.href = '/logout'

  $('#password_forget').on 'click', () ->
    $('#top_choice').hide()
    $('#top_login').hide()
    $('#top_register').hide()
    $('#top_activate').hide()
    $('#top_password_forget').show()
    $('#top_password_change').hide()
