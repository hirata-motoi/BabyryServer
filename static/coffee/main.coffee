if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->
$ ->

showRelatives = () -> 
  relatives = $.parseJSON( $(".relatives-data").attr("data-json")  )
  
  relatives_list = for key of relatives
    window.console.log( relatives[key] )
    relative_id    = key 
    relative_email = relatives[key].email || ""
    "id:" + relative_id + " email:" + relative_email
 
  window.confirm( relatives_list.join("\n") )

getXSRFToken = ->
  window.console.log document.cookie
  cookies = document.cookie.split(/\s*;\s*/)
  for c in cookies
    matched = c.match(/^XSRF-TOKEN=(.*)$/)
    token = matched[1] if matched?
  return token


setXSRFTokenToForm = () ->
  window.console.log("bbb")
  token = getXSRFToken
  $("form").each( (i, form) ->
    method = $(form).attr("method")
    window.console.log("aaa")
    return if method is "get" or method is "GET"

    $input = $("<input>")
    $input.attr("type", "hidden")
    $input.attr("name", "XSRF-TOKEN")
    $input.attr("value", token)

    window.console.log $(form)
    $(form).append($input)
  )

$("#show-relatives").on('click', showRelatives)
setXSRFTokenToForm()



