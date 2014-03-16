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

searchUser = () ->
  searchString = $("#search-form").val()
  $("#search-result-container").empty()
  token = getXSRFToken()
  $.ajax({
    "url": "/relatives/search.json",
    "type": "post",
    "data": {
      "str": searchString,
      "XSRF-TOKEN": token,
    },
    "dataType": "json",
    "success": (data) ->
      return if ! data.users
      for user, index in data.users
        searchResult = $("<li>")
        searchResult.attr "user-id", user.user_id
        searchResult.addClass "search-result"

        window.console.log user.relative_status

        if user.relative_relation == 'approved'
          # 既にrelativesになっている場合
          # serverで除外しているが一応ケアする
          continue
        else if user.relative_relation == 'applying'
          # 自分から申請中
          applyIcon = createApplyingText()
        else if user.relative_relation == 'admitting'
          # 相手から申請中
          applyIcon = createAdmittingIcon()
        else
          applyIcon = createRelativesApplyIcon()

        searchResult.text user.user_name
        searchResult.append applyIcon
        $("#search-result-container").append searchResult
    "error": () ->
      # 失敗した旨のメッセージを出す
  })

createAdmittingIcon = () ->
  icon = $("<button>")
  icon.addClass("relatives-apply-icon")
  icon.text("承認する")
  icon.on "click", admitRelativeApply
  return icon


admitRelativeApply = () ->
  button = $(this)
  searchResult = button.parents(".search-result")
  userId = searchResult.attr("user-id")
  token = getXSRFToken()
  
  # loadingアイコン
  button.text("")
  button.append createloadingIcon()
  
  $.ajax({
    "url": "/relatives/admit.json",
    "type": "post",
    "data": {
      "user_id": userId,
      "XSRF-TOKEN": token
    },
    "success": () ->
      # 承認するボタンを「承認済み」に変更
      button.remove()
      admittedText = createAdmittedText()
      searchResult.append admittedText

      # 友達リストに「承認済み」枠で表示
      refleshRelativesList()
    "error": () ->
      # 失敗した旨を表示
  })

createRelativesApplyIcon = () ->
  icon = $("<button>")
  icon.addClass("relatives-apply-icon")
  icon.text("申請")
  icon.on "click", sendRelativeApply
  return icon

sendRelativeApply = () ->
  button = $(this)
  searchResult = button.parents(".search-result")
  userId = searchResult.attr("user-id")
  token = getXSRFToken()

  # loadingアイコン
  button.text("")
  button.append createloadingIcon()

  $.ajax({
    "url": "/relatives/apply.json",
    "type": "post",
    "data": {
      "user_id": userId,
      "XSRF-TOKEN": token
    },
    "success": () ->
      # 申請ボタンを「申請中」に変更
      button.remove()
      applyingText = createApplyingText()
      searchResult.append applyingText

      # 友達リストに「申請中」枠で表示
      refleshRelativesList()
    "error": () ->
      # 失敗した旨を表示
  })

createApplyingText = () ->
  applyingText = $("<span>")
  applyingText.addClass "relatives-apply-icon"
  applyingText.text("申請中")
  return applyingText

createAdmittedText = () ->
  applyingText = $("<span>")
  applyingText.addClass "relatives-apply-icon"
  applyingText.text("承認済み")
  return applyingText

createloadingIcon = () ->
  img = $("<img>")
  img.attr "src", "/static/img/ajax-loader.gif"
  img.addClass "loading-image"
  return img

refleshRelativesList = () ->
  $.ajax({
    "url": "/relatives/list.json",
    "type": "get",
    "success": (data) ->
      # relatives listのDOMを入れ替える
      return if ! data.relatives
     
      elems = []
      for relative_id of data.relatives
        email = data.relatives[relative_id].email
        elem = $("<li>")
        elem.text relative_id + " : " + email
        elems.push elem
        
      list = $("#list .list-view")
      list.empty()
      for e in elems
        list.append e

    "error": () ->
      # 更新に失敗した旨を表示
  })

$("#search-submit").on "click", searchUser
refleshRelativesList()

