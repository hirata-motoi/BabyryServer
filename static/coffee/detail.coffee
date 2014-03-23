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
showImageDetail = () ->
  $(".img-thumbnail").on("click", () ->

    window.util.showPageLoading()

    # .containerのpaddingをなくす
    $(".container").addClass "full-size-screen"

    # screenサイズを取得
    screenWidth = screen.width
    screenHeight = screen.height
    $(".container.content-body").css "width", screenWidth
    $(".container.content-body").css "height", screenHeight

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

      $elem = createImageBox image_url, image_id, comment_count, screenWidth, screenHeight
      owlContainer.append $elem
      initialIndex = i if data.list[i] and data.list[i].image_id == imageId
      
      if stamps
        stampList = []
        for stampInfo, n in stamps
          stampElem = createStamp(stampInfo.stamp_id, stampInfo.icon_url)
          $elem.find(".stamp-container").append stampElem

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
        adjustDisplayedElements()
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

    # +ボタンのeventを登録
    $(".stamp-attach-icon").on "click", attachStamp

    window.util.hidePageLoading()
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
        media = $("<div>")
        media.addClass("media")
        
        icon = $("<a>")
        icon.addClass("pull-left")
        icon.attr("href", "#")

        img = $("<img>")
        img.addClass("media-object")
        img.attr("alt", "64x64")
        img.attr("src", "/static/img/160x160.png")
        img.css("width", "64px")
        img.css("height", "64px")

        icon.append img
        media.append icon

        mediaBody = $("<div>")
        mediaBody.addClass("media-body")

        h4 = $("<h4>")
        h4.addClass("media-heading")
        h4.val("Media heading")

        mediaBody.append h4
        mediaBody.text(comment)

        media.append mediaBody

        $(".comment-container").prepend media
        window.entryData.entries[currentPosition].comments.push {"comment": comment}

        # textareaを空にする
        $("#comment-textarea").val("")

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


  createImageBox = (image_url, image_id, comment_count, screenWidth, screenHeight) ->
    tmpl = $("#item-tmpl").clone(true)
    owlElem = $(tmpl)
    owlElem.find(".img-box").attr "image-id", image_id
    owlElem.find(".img-box").css "background-image", "url(" + image_url + ")"
    owlElem.css "width", screenWidth
    owlElem.css "height", screenHeight
    owlElem.attr "id", ""

    owlElem.addClass("unloaded") if !image_url
    owlElem.find(".img-box").on "click", toggleDisplayedElements

    # コメントの件数表示
    commentNoticeString = createCommentNavigation(comment_count)
    owlElem.find(".comment-notice").text commentNoticeString

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

  attachStamp = () ->
    # スタンプをタップされたら画像にstampをつける
    # stampのidはaタグのstamp-idというattrに仕込んでおく

    stampId = $(this).attr("stamp-id")

    # image_idはowlのcurrentPositionから取得する
    currentPosition = owlObject.currentPosition()

    # 既にattach済なら何もしない
    return if alreadyAttachedStamp stampId, currentPosition

    stampHash = getStampHash()
    stampIconUrl = stampHash[stampId].icon_url
    targetImgBox = $(".img-box")[currentPosition]
    imageId = $(targetImgBox).attr("image-id")

    # stampのDOMを作ってappend
    stampElem = createStamp(stampId, stampIconUrl)
    $(targetImgBox).find(".stamp-container").append stampElem

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
          stampsByImagePosition[currentPosition][stampId] = false
    })

  createStamp = (stampId, stampIconUrl) ->
    stampElem = $("<li>")
    stampElem.addClass "stamp"

    stampImage = $("<img>")
    stampImage.addClass "stamp-icon"
    stampImage.attr "src", stampIconUrl
    stampImage.attr "stamp-id", stampId

    # detach event
    stampImage.on "click", detachStamp

    stampElem.append stampImage
    return stampElem

  detachStamp = (e) ->
    e.stopPropagation()

    elem = $(this)
    stampId = elem.attr("stamp-id")
    imageId = elem.parents(".img-box").attr("image-id")
    currentPosition = owlObject.currentPosition()

    # stampを非表示にする
    elem.hide()

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
        elem.remove()
        # stampsByImagePositionをfalseにする
        stampsByImagePosition[currentPosition][stampId] = false
      "error": (xhr, textStatus, errorThrown) ->
        elem.show()
    })

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
      $("#stampAttachModal").find(".modal-body").append elem

  backToWall = () ->
    $(".container").removeClass "full-size-screen"
    location.href = "/"

  toggleDisplayedElements = () ->
    $(".navbar").toggle()
    window.displayedElementsFlg = if $(".navbar").css("display") == "none" then false else true
    adjustDisplayedElements()

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

  createCommentNavigation = (comment_count) ->
    "コメント" + comment_count + "件"

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
