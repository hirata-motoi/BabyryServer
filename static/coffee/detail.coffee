if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->
$ ->


###
set event to click each image
this part will be replaced by methods in entries.coffee
###

window.entryData or= {}
window.entryData.entries or= []
window.entryData.metadata or= {}
window.stampData or= {}
window.stampsByImagePosition or= {}
window.stamp_ids or = []

window.entryIdsInArray = []
window.loadingFlg = false
window.displayedElementsFlg = true
owlObject = undefined
defaultTextareaHeight = "30px"
showImageDetail = () ->
  $(".img-thumbnail").on("click", () ->
    # styleに画面の大きさを設定
    setUpScreenSize()

    window.util.showPageLoading()

    # .containerのpaddingをなくす
    $(".container").addClass "full-size-screen"

    # screenサイズを取得
    innerWidth = window.innerWidth
    innerHeight = window.innerHeight
    $(".container.content-body").css "width", innerWidth
    $(".container.content-body").css "height", innerHeight

    imageId   = $(this).parents(".item").attr("image_id")
    data = pickData()
    tappedEntryIndex = $(this).attr "entryIndex"
  
    # setup stampsByImagePosition
    upsertStampsByImagePosition data.list

    owlContainer = $(".owl-carousel").clone(true)
    owlContainer.addClass("displayed")

    # create new contents
    for i in [0 .. data.found_row_count - 1]

      if data.list[i]
        image_url = data.list[i].fullsize_image_url
        window.entryIdsInArray.push data.list[i].image_id
        stamps = data.list[i].stamps
        image_id = data.list[i].image_id
        comment_count = data.list[i].comments.length
      else 
        image_url = ""
        image_id  = ""
        comment_count = 0

      $elem = createImageBox image_url, image_id, comment_count, innerWidth, innerHeight
      owlContainer.append $elem
      initialIndex = i if data.list[i] and data.list[i].image_id == imageId
      
      if stamps
        stampList = []
        for stampInfo, n in stamps
          stampElem = createStamp(stampInfo.stamp_id, stampInfo.icon_url)
          $elem.find(".stamp-container").append stampElem
      $elem.find(".stamp-container").hide()

    # hide navbar-space
    $("#navbar-space").hide()
    # replace html of container
    $(".dynamic-container").html( owlContainer )
    $(window).scrollTop(0)

    # set carousel
    $(".owl-carousel.displayed").owlCarousel({
      items: 1,
      pagination: false,
      scrollPerPage: true,
      beforeMove: () ->
      afterMove: () ->
        replaceToolBoxContent()
#adjustDisplayedElements()
        if shouldPreLoad(5)
          return if window.loadingFlg

          # 前回取得したページno
          currentPageNo = 1

          # いくつentryを取得するか
          count = 10

          # とりあえず1つぐるぐるをだしておく
          showLoadingImage()

          # loading flg
          loadingFlg = true

          # ajax
          getData showEntries, showErrorMessage
    });

    # owlObjectをメモリに保持
    owlObject = $(".owl-carousel").data("owlCarousel")

    # タップされた画像を初期位置へ
    owlObject.jumpTo(tappedEntryIndex)

    window.util.hidePageLoading()

    # footer
    showNavBarFooter()
  )

  $("#comment-submit").on("click", () ->
    token = getXSRFToken()
    comment = $("#comment-textarea").val()
    currentPosition = owlObject.currentPosition()
    imageElem = $(".img-box")[currentPosition]
    imageId = $(imageElem).attr("image-id")

    $.ajax({
      "type": "post",
      "url" : "/image/comment.json",
      "data": {
        "image_id": imageId,
        "comment" : comment
        "XSRF-TOKEN": token
      },
      "dataType": "json",
      "success" : (data) ->
        tmpl = _.template $('#template-comment-item').html()
        item = tmpl
          commenter_icon_url: data.commented_by_icon_url,
          commenter_name: data.commented_by_name,
          comment_text: data.comment
        $("#all-comment-container").find("ul").append item

        window.entryData.entries[currentPosition].comments.push {"comment": comment}

        # textareaを空にする
        $("#comment-textarea").val("")
        
        # textareaの高さを戻す
        $("#comment-textarea").css "height", defaultTextareaHeight

        # コメント件数を変更
        commentCount = window.entryData.entries[currentPosition].comments.length
        $(imageElem).find(".comment-notice").text createCommentNavigation(commentCount)

    })
    
  )

  shouldPreLoad = (num) ->
    # TODO improve
    return if window.entryIdsInArray.length < owlObject.currentPosition() + num then true else false

  preserveResponseData = (response) ->
    window.entryData.entries.push entry for entry in response.data.entries
    window.entryData.metadata = response.metadata

  pickData = () ->
    return {
      list: window.entryData.entries,
      found_row_count: window.entryData.metadata.found_row_count
    }

  getData = (successCallback, errorCallback) ->
    nextPage = if window.entryData.metadata.page then parseInt(window.entryData.metadata.page, 10) + 1 else 1
    countPerPage = window.entryData.metadata.count || 10
    # ajax
    $.ajax({
      "url" : "/entry/search.json",
      "processData": true,
      "contentType": false,
      "data": {
        stamp_id: window.stamp_ids,
        "page": nextPage,
        "count": countPerPage
      },
      "dataType": 'json',
      "success": successCallback
      "error": errorCallback
    })


  createImageBox = (image_url, image_id, comment_count, innerWidth, innerHeight) ->
    tmpl = $("#item-tmpl").clone(true)
    owlElem = $(tmpl)
    owlElem.find(".img-box").attr "image-id", image_id
    owlElem.find(".img-box").css "background-image", "url(" + image_url + ")"
    owlElem.css "width", innerWidth
    owlElem.css "height", innerHeight
    owlElem.attr "id", ""

    owlElem.addClass("unloaded") if !image_url
    owlElem.find(".img-box").on "click", toggleDisplayedElements

    # stamp編集ボタン
#   owlElem.find(".stamp-edit").on "click", () ->
#      $("#stampAttachModal").modal("show")

    # コメントの件数表示
#    commentNoticeString = createCommentNavigation(comment_count)
#    owlElem.find(".comment-notice").text commentNoticeString

    owlElem.find(".comment-notice").on "click", () ->
      $(".comment-container").empty()

      currentPosition = owlObject.currentPosition()
      comments = window.entryData.entries[currentPosition].comments

      comments.sort( (a, b) ->
        aCreatedAt = a.created_at
        bCreatedAt = b.created_at
        if aCreatedAt < bCreatedAt
          return -1
        if aCreatedAt > bCreatedAt
          return 1
        return 0
      )

      tmpl = _.template $('#template-comment-item').html()
      if comments
        for comment in comments
          item = tmpl
            commenter_icon_url: comment.commented_by_icon_url,
            commenter_name: comment.commented_by_name,
            comment_text: comment.comment

          $(".comment-container").prepend item
      $("#commentModal").modal("show")
    owlElem.show()
    return owlElem

  showLoadingImage = () ->
    $(".unloadedElems").first().find(".img-box img").attr("src", "/static/img/ajax-loader.gif")

  showErrorMessage = () ->
    # TODO implement

  showEntries = (response) ->
    return if response.data.entries.length < 1

    preserveResponseData response

    unloadedElems = $(".unloaded");
    for elem, i in unloadedElems
      if response.data.entries[i]
        image_url = response.data.entries[i].fullsize_image_url
        $(elem).find(".img-box").css "background-image", "url('" + image_url + "')"
        $(elem).find(".loading").removeClass("loading")
        $(elem).removeClass("unloaded")
        window.entryIdsInArray.push response.data.entries[i].image_id
      else
        window.loadingFlg = false
        break
    window.loadingFlg = false

  getNextIds = () ->
    # 取得すべきentryのoffsetと数を取得
    currentEntryId = getCurrentEntryId

  getCurrentEntryId = () ->
    # 今表示されている投稿のentry_id
  
  alreadyAttachedStamp = (stampId, currentPosition) ->
    window.stampsByImagePosition[currentPosition] or= {}
    return if window.stampsByImagePosition[currentPosition][stampId] == true then true else false

  setStampsByImagePosition = (stampId, currentPosition, value) ->
    window.stampsByImagePosition[currentPosition] or= {}
    window.stampsByImagePosition[currentPosition][stampId] = value

  upsertStampsByImagePosition = (entries) ->
    for entry, i in entries
      window.stampsByImagePosition[i] or= {}
      for stamp, n in entry.stamps
        window.stampsByImagePosition[i][stamp.stamp_id] = true

  toggleStamp = () ->
    # スタンプをタップされたら画像にstampをつける
    # stampのidはaタグのstamp-idというattrに仕込んでおく

    stampId = $(this).attr("stamp-id")

    # image_idはowlのcurrentPositionから取得する
    currentPosition = owlObject.currentPosition()

    stampHash = getStampHash()
    stampIconUrl = stampHash[stampId].icon_url
    targetImgBox = $(".img-box")[currentPosition]
    imageId = $(targetImgBox).attr("image-id")
    target = $("#attached-stamps-container")

    # 既にattach済ならdetachする
    if alreadyAttachedStamp stampId, currentPosition
      # detach
      # stampを非表示にする
      targetStamp = target.find('img[stamp-id="' + stampId + '"]').parent()
      targetStamp.hide()

      # edit-stamp-container内のスタンプのgrayscaleを外す
      $(this).find("img").removeClass "icon-grayscale"

      token = getXSRFToken()
      $.ajax({
        "url" : "/stamp/detach.json",
        "type": "post",
        "data": {
          "image_id": imageId,
          "stamp_id": stampId,
          "XSRF-TOKEN": token
        },
        "dataType": "json",
        "success": (response) ->
          # successならDOMを消す
          targetStamp.remove()

          # stamp-containerからも消す
          window.console.log $(targetImgBox).find('img[stamp-id="' + stampId + '"]').parent()
          stampContainer = $(targetImgBox).find('img[stamp-id="' + stampId + '"]').parent()
          stampContainer.remove()

          # stampsByImagePositionをfalseにする
          window.stampsByImagePosition[currentPosition][stampId] = false
        "error": (xhr, textStatus, errorThrown) ->
          targetStamp.show()
          $(this).find("img").addClass "icon-grayscale"
      })
    else
      # attach
      # stampのDOMを作ってappend
      stampElem = createStamp(stampId, stampIconUrl)
      $("#attached-stamps-container").find("ul").append stampElem
      $(targetImgBox).find(".stamp-container").append stampElem.clone(true)
      
      # edit-stamp-container内のスタンプのgrayscaleを外す
      $(this).find("img").addClass "icon-grayscale"

      # stampsByImagePositionを更新
      setStampsByImagePosition stampId, currentPosition, true

      token = getXSRFToken()
      $.ajax({
        "url" : "/stamp/attach.json",
        "type": "post",
        "data": {
          "image_id": imageId,
          "stamp_id": stampId,
          "XSRF-TOKEN": token
        },
        "dataType": "json",
        "error"   : (xhr, textStatus, errorThrown) ->
          # TODO リクエストに失敗したらstampsByImagePositionをfalseにする
          # ただし、「既にstampされています」というメッセージだった場合だけは何もしない
          # 心苦しいが正規表現で暫定対応する カンベン
          res = $.parseJSON(xhr.responseText)
          regexp = new RegExp("stamp", "i")
          if res.error_messages.stamp_id and  res.error_messages.stamp_id[0].match(regexp)
            # 多分「既にstampされています」なのでスルー
          else
            # stampsByImagePositionをfalseにする
            window.stampsByImagePosition[currentPosition][stampId] = false
            stampElem.remove()
            $(this).find("img").removeClass "icon-grayscale"
      })


  createStamp = (stampId, stampIconUrl) ->
    stampElem = $("<li>")
    stampElem.addClass "stamp"

    stampImage = $("<img>")
    stampImage.addClass "stamp-icon"
    stampImage.attr "src", stampIconUrl
    stampImage.attr "stamp-id", stampId

    stampElem.append stampImage
    return stampElem

  getStampHash = () ->
    #return window.stampData
    stampHash = {}
    for stamp in window.stampData
      stampHash[stamp.stamp_id] = stamp
    return stampHash

  getXSRFToken = ->
    cookies = document.cookie.split(/\s*;\s*/)
    for c in cookies
      matched = c.match(/^XSRF-TOKEN=(.*)$/)
      token = matched[1] if matched?
    return token

  createStampAttachIcon = (stamp) ->
    elem = $("<a>")
    elem.addClass("stamp-attach-icon")
    elem.attr("stamp-id", stamp.stamp_id)
    img  = $("<img>")
    img.attr("src", stamp.icon_url)
    img.addClass("listed-stamp")

    elem.append img
    elem.on "click", toggleStamp 
    return elem

  hasElem = (data) ->
    for i in data
      return true
    return false

  getStampData = () ->
    return window.stampData

  setStampAttachList = () ->
    stampList = getStampData()
    for stamp, i in stampList
      elem = createStampAttachIcon stamp
      #$("#stampAttachModal").find(".modal-body").append elem
      $("#stamp-edit-container").append elem

  backToWall = () ->
    $(".container").removeClass "full-size-screen"
    location.href = "/"

  toggleDisplayedElements = () ->
    $(".navbar").toggle()
    window.displayedElementsFlg = if $(".navbar").css("display") == "none" then false else true
#adjustDisplayedElements()

  # TODO 不要になるかも
  adjustDisplayedElements = () ->
    # currentPositionとその前後2つのimg-box上のdisplayedElementsをtoggleする
    currentPosition = parseInt owlObject.currentPosition(), 10
    elems = $(".img-box")

    if window.entryData.entries.length < 4
      indexes = [0 .. window.entryData.entries.length - 1]
    else if currentPosition == 0
      # first image
      indexes = [0, 1]
    else if currentPosition == window.entryData.entries.length - 1
      # last image
      indexes = [currentPosition + 0 -1, currentPosition]
    else
      indexes = [currentPosition, currentPosition - 1, currentPosition + 0 + 1 ]

    for i in indexes
      imageElem = $( elems[i] )
      if window.displayedElementsFlg 
        imageElem.find(".stamp-container").show()
        imageElem.find(".img-footer").show()
      else 
        imageElem.find(".stamp-container").hide()
        imageElem.find(".img-footer").hide()

  replaceToolBoxContent = () ->
    currentPosition = parseInt owlObject.currentPosition(), 10
    elems = $(".img-box")
    # stampの入れ替え
    stampContainer = $( $(elems)[currentPosition] ).find(".stamp-container").clone(true)
    $("#attached-stamps-container").find("ul").html stampContainer.html()

    # コメントの入れ替え
    $("#recent-comment-container").empty()
    comments = window.entryData.entries[currentPosition].comments

    if comments and comments.length > 0
      comments.sort( (a, b) ->
        aCreatedAt = a.created_at
        bCreatedAt = b.created_at
        if aCreatedAt < bCreatedAt
          return -1
        if aCreatedAt > bCreatedAt
          return 1
        return 0
      )
      commentItem = $("<span>")
      commentItem.text comments[0].comment
      $("#recent-comment-container").append commentItem
      commentCount = comments.length
    else
      commentCount = 0

    # コメント件数の入れ替え
    commentCountText = createCommentNavigation commentCount
    $("#comment-count").text commentCountText

  createCommentNavigation = (comment_count) ->
    "コメント" + comment_count + "件"

  showNavBarFooter = () ->
    $("#comment-count").on "click", showComments
    $("#comment-box").on "click", showComments
    $("#modal-header").on "click", closeComments
    $("#stamp-edit").on "click", editStamps
    $(".navbar-footer").show()

  showComments = () ->
    container = $("#all-comment-container")
    currentPosition = parseInt owlObject.currentPosition(), 10
    comments = window.entryData.entries[currentPosition].comments
    comments.sort( (a, b) ->
      aCreatedAt = a.created_at
      bCreatedAt = b.created_at
      if aCreatedAt < bCreatedAt
        return -1
      if aCreatedAt > bCreatedAt
        return 1
      return 0
    )
    if comments.length > 0
      tmpl = _.template $('#template-comment-item').html()
      list = for comment in comments
        item = tmpl
          commenter_icon_url: comment.commented_by_icon_url,
          commenter_name: comment.commented_by_name,
          comment_text: comment.comment

    window.console.log comments.length
    container.find("ul").empty()
    container.find("ul").append list
    $(".navbar-footer").addClass("all-comment-container-opened")
    $("#attached-stamps-container").hide()
    $("#stamp-edit-container").hide()
    $("#recent-comment-container").hide()
    $("#comment-operation-container").hide()
    $("#comment-input-container").show()
    $("#comment-input-container").find("textarea").focus() if ! comments.length
    $("#modal-header").show()
    container.show()

  closeComments = () ->
    $(".navbar-footer").removeClass("all-comment-container-opened")
    $("#attached-stamps-container").show()
    $("#stamp-edit-container").hide()
    $("#recent-comment-container").show()
    $("#comment-operation-container").show()
    $("#comment-input-container").hide()
    $("#all-comment-container").hide()
    $("#modal-header").hide()

  editStamps = () ->
    # attachedStampsとeditStamp以外は非表示
    $(".navbar-footer").addClass("all-comment-container-opened")
    $("#stamp-edit-container").show()
    # stamp-edit-containerのアイコンのgrayscaleをセット
    setEditStampGrayscale()
    $("#recent-comment-container").hide()
    $("#comment-operation-container").hide()
    $("#comment-input-container").hide()
    $("#modal-header").show()

  setUpScreenSize = () ->
    screenHeight = window.innerHeight - 44
    rule = ".all-comment-container-opened { height: " + screenHeight + 'px; }'
    ss = document.styleSheets
    $(ss).each () ->
      window.console.log $(this)[0].title
      if $(this)[0].title == "dynamic"
        idx = $(this)[0].cssRules.length;
        $(this)[0].insertRule rule, idx

  setEditStampGrayscale = () ->
    container = $("#stamp-edit-container")
    currentPosition = parseInt owlObject.currentPosition(), 10
    stamps = window.stampsByImagePosition[currentPosition]
    for stampId of stamps
      if stamps[stampId] == true
        container.find("a[stamp-id=" + stampId + "]").find("img").addClass "icon-grayscale"

  # stamp attach用のmodalのsetup
  if ! hasElem(window.stampData)
    $.ajax({
      "url" : "/stamp/list.json", 
      "type": "get",
      "processData": true,
      "contentType": false,
      success: (response) ->
        window.stampData = response.data
        setStampAttachList()
    })
  else
    setStampAttachList()

window.util ||= {}
window.util.showImageDetail = showImageDetail
