if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->
$ ->

getXSRFToken = ->
  cookies = document.cookie.split(/\s*;\s*/)
  for c in cookies
    matched = c.match(/^XSRF-TOKEN=(.*)$/)
    token = matched[1] if matched?
  return token

inviteSubmit = () ->
  token = getXSRFToken()
  $.ajax({
    "url": "/invite/execute",
    "type": "post",
    "data": {
      "XSRF-TOKEN": token,
      "aaaa": "bbbbbbbb",
    },
    "dataType": "json"
    "success": (data) ->
      # メーラーを起動する
      query  = "?subject=" + data.subject + "&body=" + data.body
      mailto = "mailto:" + query
      location.href = mailto;
    "error": () ->
      window.console.log "error"
  })
$("#invite-submit").on("click", inviteSubmit)

inviteLineSubmit = () ->
  window.console.log "test"
  token = getXSRFToken()
  $.ajax({
    "url": "/invite/execute",
    "type": "post",
    "data": {
      "XSRF-TOKEN": token,
      "aaaa": "bbbbbbbb",
    },
    "dataType": "json"
    "success": (data) ->
      window.open 'http://line.me/R/msg/text/?' + data.body, '_blank', 'menubar=yes,location=yes,status=yes,resizable=yes,scrollbars=yes'
    "error": () ->
      # エラーメッセージを表示
  })
$("#invite-line-submit").on("click", inviteLineSubmit)
