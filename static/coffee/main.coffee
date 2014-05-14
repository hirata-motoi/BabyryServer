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

  target.find("a").css "border-bottom", "solid 3px rgba(255, 230, 62, 1.0)"
  target.find("img").css "margin-bottom", "-3px"

setHeaderElem = () ->
  path = location.pathname
  if path == "/"
    $("#album-view").show()
  else
    $("#album-view").hide()

  
window.util ||= {}
window.util.showPageLoading = showPageLoading
window.util.hidePageLoading = hidePageLoading
$(document).on "DOMContentLoaded", () ->
  showFooterEffect()
  setHeaderElem()

