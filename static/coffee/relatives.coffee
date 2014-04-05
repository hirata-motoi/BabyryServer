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

        searchResult.append createIcon(user.icon_url)
        searchResult.append createUserName(user.user_name);

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
  icon.text("承認")
  icon.on "click", admitRelativeApply
  icon.addClass "admit-button-icon"
  return icon

createCancelIcon = () ->
  cancelIconDiv = $("<div>")
  cancelIconDiv.addClass "cancel-icon-div"

  icon = $("<button>")
  icon.addClass("relatives-operation-icon")
  icon.text("取消")
  icon.on "click", cancelRelativeApply

  cancelIconDiv.append icon
  return cancelIconDiv

createRejectIcon = () ->
  icon = $("<button>")
  icon.addClass("relatives-operation-icon")
  icon.text("拒否")
  icon.on "click", rejectRelativeApply
  icon.addClass "reject-button-icon"
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
  applyIconDiv = $("<div>")
  applyIconDiv.addClass "apply-icon-div"

  applyIcon = $("<button>")
  applyIcon.addClass("relatives-operation-icon")
  applyIcon.text("申請")
  applyIcon.on "click", sendRelativeApply

  applyIconDiv.append applyIcon
  return applyIconDiv

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
      refreshRelativesList()
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
  target = button.parents(".list-view-item")
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
refreshRelativesList = () ->
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

          elem.append createIcon(data.relatives[relation][relative_id].icon_url)
          elem.append createUserName(data.relatives[relation][relative_id].user_name)

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

createIcon = (icon_url) ->
  imgDiv = $("<div>")
  imgDiv.addClass "icon-image-parent-div"
  img = $("<img>")
  img.attr "src", icon_url
  img.addClass "icon-image"
  img.on "load", trimIcon 
  imgDiv.append img
  return imgDiv

createUserName = (user_name) ->
  userNameDiv = $("<div>")
  userNameDiv.addClass "user-name-div"
  userName = $("<span>")
  userName.addClass "user-name-elem"
  userName.text user_name
  userNameDiv.append  userName
  return userNameDiv

trimIcon = () ->
  # 表示時のicon縦横サイズ
  imgDisplaySize = 64

  img = $(this)[0]
  nw = img.naturalWidth
  nh = img.naturalHeight

  # size : trim後の縦横サイズ
  if nw > nh
    rh = imgDisplaySize
    rw = imgDisplaySize * nw / nh
  else
    rw = imgDisplaySize
    rh = imgDisplaySize * nh / nw

  iw = (rw - imgDisplaySize) / 2
  ih = (rh - imgDisplaySize) / 2
  $(img).css "top", "-"+ih+"px"
  $(img).css "left", "-"+iw+"px"
  $(img).css "width", rw+"px"
  $(img).css "height", rh+"px"

# タブが切り替わった時には検索条件と検索結果をresetしておく
# listのタブでrelativesとの関係が変更される可能性があり、
# searchのタブの内容が実際と食い違う可能性があるため
$('a[data-toggle="tab"]').on "shown.bs.tab", () ->
  $("#search-form").val("")
  $("#search-result-container").empty()

$("#search-submit").on "click", searchUser
refreshRelativesList()

