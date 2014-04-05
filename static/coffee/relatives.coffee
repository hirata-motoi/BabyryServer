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

searchUser = () ->
  searchString = $("#search-form").val()
  $("#search-result-container").empty()
  $.mobile.loading("show", {})
  $.ajax({
    "url": "/relatives/search.json",
    "type": "get",
    "processData": true,
    "data": {
      "str": searchString,
    },
    "dataType": "json",
    "success": (data) ->
      $.mobile.loading("hide")

      return if ! data.users

      for user, index in data.users
        searchResult = $("<li>")
        searchResult.attr "user-id", user.user_id
        searchResult.addClass "list-view-item"
        img = $("<img>")
        img.attr "src", user.icon_url
        searchResult.append img
        searchResult.append $("<h2>").text user.user_name

        if user.relative_relation == "approved" || user.relative_relation == "admitting" || user.relative_relation == "applying"
          # 既にrelativesになっている場合、申請中の場合はここに出さない
          # approvedの場合はserverで除外しているが一応ケアする
          continue
        else
          applyIcon = createRelativesApplyIcon()

        searchResult.append applyIcon
        $("#search-result-container").append searchResult
        $("#search-result-container").listview("refresh")
    "error": () ->
      # 失敗した旨のメッセージを出す
      $.mobile.loading("hide")
  })

createAdmittingIcon = () ->
  icon = $("<button>")
  icon.addClass("relatives-operation-icon")
  icon.text("承認する")
  icon.on "click", admitRelativeApply
  return icon

createCancelIcon = () ->
  icon = $("<button>")
  icon.addClass("relatives-operation-icon")
  icon.text("取り消す")
  icon.on "click", cancelRelativeApply
  return icon

createRejectIcon = () ->
  icon = $("<button>")
  icon.addClass("relatives-operation-icon")
  icon.text("拒否")
  icon.on "click", rejectRelativeApply
  return icon

admitRelativeApply = () ->
  button = $(this)
  item = button.parents(".list-view-item")
  userId = item.attr("user-id")
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
      # 承認待ちlistから消して友達listに追加する
      container = item.parents(".list-view-item-container")
      clonedItem = item.clone()
      item.remove()
      clonedItem.find("button").remove()
      $("#approved").find("ul").prepend clonedItem
      # approvedが今まで1件もなかった場合のため
      $("#approved").show()

      # itemがなくなった項目は非表示にする
      # list-view-itemが一つもない状態になったら項目自体を隠す
      if container.find(".list-view-item").length < 1
        container.hide()
      $("#approved-list").listview("refresh")
    "error": () ->
      # 失敗した旨を表示
  })

createRelativesApplyIcon = () ->
  icon = $("<button>")
  icon.addClass("relatives-operation-icon")
  icon.text("申請")
  icon.on "click", sendRelativeApply
  return icon

sendRelativeApply = () ->
  button = $(this)
  searchResult = button.parents(".list-view-item")
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
  applyingText.addClass "relatives-operation-icon"
  applyingText.text("申請中")
  return applyingText

createAdmittedText = () ->
  applyingText = $("<span>")
  applyingText.addClass "relatives-operation-icon"
  applyingText.text("承認済み")
  return applyingText

createloadingIcon = () ->
  img = $("<img>")
  img.attr "src", "/static/img/ajax-loader.gif"
  img.addClass "loading-image"
  return img

requestRelativeOperate = (button, url) ->
  target = button.parent(".list-view-item")
  tab = button.parents(".tab-pane").attr "id"
  userId = target.attr("user-id")
  token = getXSRFToken()
  
  # loadingアイコン
  button.text("")
  button.append createloadingIcon()
  
  $.ajax({
    "url": url,
    "type": "post",
    "data": {
      "user_id": userId,
      "XSRF-TOKEN": token
    },
    "success": () ->
      # list-view-itemが一つもない状態になったら項目自体を隠す
      container = target.parents(".list-view-item-container")
      
      # 申請中リストから削除
      target.remove()

      if container.find(".list-view-item").length < 1
        container.hide()

    "error": () ->
      # 失敗した旨を表示
  })

cancelRelativeApply = () ->
  button = $(this)
  url = "/relatives/cancel.json"
  requestRelativeOperate button, url

rejectRelativeApply = () ->
  button = $(this)
  url = "/relatives/reject.json"
  requestRelativeOperate button, url

# relatives listを再表示
refleshRelativesList = () ->
  $.ajax({
    "url": "/relatives/list.json",
    "type": "get",
    "success": (data) ->
      # relatives listのDOMを入れ替える
      return if ! data.relatives
     
      elems = {}
      for relation of data.relatives
        elems[relation] = []
        for relative_id of data.relatives[relation]
          email = data.relatives[relation][relative_id].email
          elem = $("<li>")
          elem.attr "user-id", relative_id
          elem.addClass("list-view-item")

          img = $("<img>")
          img.attr "src", data.relatives[relation][relative_id].icon_url
          elem.append img
          elem.append $("<h2>").text(data.relatives[relation][relative_id].user_name)

          if relation == "applying"
            # 申請中の場合はキャンセルボタンを作る
            elem.append createCancelIcon()
          else if relation == "admitting"
            # 承認待ちの場合は承認ボタン・拒否ボタンを作る
            elem.append createRejectIcon()
            elem.append createAdmittingIcon("list")
            
          elems[relation].push elem
        
      list = $("#list .list-view")
      list.find("li").hide()
      list.find("ul").empty()

      for r of elems 
        $("#" + r).show()
        for e in elems[r]
          $("#" + r + "-list").append e
          $("#" + r + "-list").listview("refresh")
        # デフォルトでアコーディオンを開いておく
        $("#" + r).find("a").trigger("click")
    "error": () ->
      # 更新に失敗した旨を表示
  })


# タブが切り替わった時には検索条件と検索結果をresetしておく
# listのタブでrelativesとの関係が変更される可能性があり、
# searchのタブの内容が実際と食い違う可能性があるため
$('a[data-toggle="tab"]').on "shown.bs.tab", () ->
  $("#search-form").val("")
  $("#search-result-container").empty()

$("#search-submit").on "click", searchUser
refleshRelativesList()

