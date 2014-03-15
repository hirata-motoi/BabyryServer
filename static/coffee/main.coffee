if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->
$ ->

getXSRFToken = ->
  window.console.log document.cookie
  cookies = document.cookie.split(/\s*;\s*/)
  for c in cookies
    matched = c.match(/^XSRF-TOKEN=(.*)$/)
    token = matched[1] if matched?
  return token


setXSRFTokenToForm = () ->
  token = getXSRFToken
  $("form").each( (i, form) ->
    method = $(form).attr("method")
    return if method is "get" or method is "GET"

    $input = $("<input>")
    $input.attr("type", "hidden")
    $input.attr("name", "XSRF-TOKEN")
    $input.attr("value", token)

    $(form).append($input)
  )

setXSRFTokenToForm()



