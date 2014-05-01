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

showPageLoading = () ->
  $.mobile.loading("show")

hidePageLoading = () ->
  $.mobile.loading("hide")

showFooterEffect = () ->
  path = location.pathname
  $(".navbar .selected-footer-menu").each () ->
    $(this).removeClass "selected-footer-menu"

  target = if path == "/"
    $("#footer-home")
  else if path == "/image/web/upload"
    $("#footer-upload")
  else
    $("#footer-other")

  window.console.log target
  target.find("a").css "border-bottom", "solid 3px rgba(255, 230, 62, 1.0)"
  target.find("img").css "margin-bottom", "-3px"

setHeaderElem = () ->
  path = location.pathname
  if path == "/"
    $("#album-view").show()
  else
    $("#album-view").hide()


  $("#babyry-title-img").on "click", () ->
    location.href = "/"


setXSRFTokenToForm()
window.util ||= {}
window.util.showPageLoading = showPageLoading
window.util.hidePageLoading = hidePageLoading
$(document).on "DOMContentLoaded", () ->
  showFooterEffect()
  setHeaderElem()

