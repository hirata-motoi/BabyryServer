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
window.entryData.related_child or= {}
window.child_ids or = []

owlObject = undefined
defaultTextareaHeight = "30px"
innerWidth  = 0
innerHeight = 0
navbarShow  = true
navbarFooterHIdeLocked  = false

showImageDetail = () ->
  $(".img-thumbnail").on("click", () ->
    # styleに画面の大きさを設定
    setUpScreenSize()

    setupGlobalFooter()

    window.util.showPageLoading()

    # screenサイズを取得
    innerWidth = window.innerWidth
    innerHeight = window.innerHeight
    $(".container.content-body").css "width", innerWidth
    $(".container.content-body").css "height", innerHeight

    imageId   = $(this).parents(".item").attr("image_id")
    tappedEntryIndex = $(this).attr "entryIndex"

    showCarousel {offset: tappedEntryIndex}, () ->
      window.util.hidePageLoading()
      # footer
      showNavBarFooter()
      # child
      data = pickData()
      setChildAttachList(data.related_child)
  )

  $("#comment-submit").on("click", () ->
    token = getXSRFToken()
    comment = $("#comment-textarea").val()
    imageElem = $(".img-box")[ getCurrentPosition() ]
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

        window.entryData.entries[ getCurrentEntryIndex() ].comments.push {"comment": comment}

        # textareaを空にする
        $("#comment-textarea").val("")
        
        # textareaの高さを戻す
        $("#comment-textarea").css "height", defaultTextareaHeight

        # コメント件数を変更
        commentCount = window.entryData.entries[ getCurrentEntryIndex() ].comments.length
        $(imageElem).find(".comment-notice").text createCommentNavigation(commentCount)

    })
    
  )

  preserveResponseData = (response) ->
    window.entryData.entries  =  response.data.entries
    window.entryData.metadata = response.metadata
    window.entryData.related_child = response.data.related_child

  pickData = () ->
    return {
      list             : window.entryData.entries,
      found_row_count  : window.entryData.metadata.found_row_count,
      related_child    : window.entryData.related_child,
      metadata         : window.entryData.metadata
    }

  getData = (offset, initial, addOnCallback) ->
    nextPage = if window.entryData.metadata.page then parseInt(window.entryData.metadata.page, 10) + 1 else 1
    countPerPage = window.entryData.metadata.count || 10
    $.mobile.loading("show")
    # ajax
    $.ajax({
      "url" : "/entry/search.json",
      "processData": true,
      "contentType": false,
      "data": {
        "child_id": window.child_ids,
        "page"    : nextPage,
        "count"   : countPerPage,
        "offset"  : offset
      },
      "dataType": 'json',
      "success" : (response) ->
        showEntries response, initial
        addOnCallback() if typeof(addOnCallback) == "function"
      "error"   : showErrorMessage
      "complete": () ->
        $.mobile.loading("hide")
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

    owlElem.find(".comment-notice").on "click", () ->
      $(".comment-container").empty()

      comments = window.entryData.entries[ getCurrentEntryIndex() ].comments

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

  showEntries = (response, initial) ->
    return if response.data.entries.length < 1

    preserveResponseData response

    ret = createOwlElementsWithResponse initial
    owlContainer = ret.owlContainer
    initialIndex = ret.initialIndex

    # .containerのpaddingをなくす
    $(".container").addClass "full-size-screen"

    $(".dynamic-container").html( owlContainer )

    # set carousel
    $(".owl-carousel.displayed").owlCarousel({
      items: 1,
      pagination: false,
      scrollPerPage: true,
      afterMove: () ->
        replaceToolBoxContent()
    })

    # owlObjectをメモリに保持
    owlObject = $(".owl-carousel.displayed").data("owlCarousel")

    # 初期位置
    owlObject.jumpTo(initialIndex)


  # WithResponseとかいいつつresopnseを直接取得してるわけではない
  # 素直にwindow.entryData内のデータを丸ごとcarouselにする
  createOwlElementsWithResponse = (initial) ->
    data   = pickData()
    count  = parseInt data.found_row_count, 10
    offset = parseInt data.metadata.offset, 10
    length = data.list.length

    initialIndex = if initial == "max"
      data.list.length - 1
    else
      0

    owlContainer = $(".owl-carousel.template").clone(true)
    owlContainer.removeClass("template")
    owlContainer.addClass("displayed")

    if 0 < offset
      # もっとみる
      moreImageBeforeElem = createImageBox "/static/img/stamp/icon/1.jpeg", 0, 0, innerWidth, innerHeight
      buttonBefore = $("<a href=\"#\" class=\"btn btn-info btn-large\">YES</a>")
      buttonBefore.on "click", () ->
        showCarousel {minIndex: offset}
        return false
      div = $("<div style=\"position: relative; margin-top: 100px\">もっとみるかニャ？</div>")
      div.append buttonBefore
      moreImageBeforeElem.find(".img-box").append div
      moreImageBeforeElem.find(".img-box").addClass("moreImage")
      owlContainer.append moreImageBeforeElem
      initialIndex = initialIndex + 1

    # carouselを作る
    for entry in data.list
      image_url = entry.fullsize_image_url
      childList = entry.child
      image_id  = entry.image_id
      comment_count = entry.comments.length
      elem = createImageBox image_url, image_id, comment_count, innerWidth, innerHeight
      owlContainer.append elem

      if childList
        for childInfo, n in childList
          childElem = createChild(childInfo.child_id, childInfo.child_name)
          elem.find(".child-container").append childElem
      elem.find(".child-container").hide()

    # もっとみる
    if count > offset + length
      moreImageAfterElem = createImageBox "/static/img/stamp/icon/1.jpeg", 0, 0, innerWidth, innerHeight
      buttonAfter = $("<a href=\"#\" class=\"btn btn-info btn-large\">YES</a>")
      buttonAfter.on "click", () ->
        showCarousel {maxIndex: offset + length - 1}
        return false
      div = $("<div style=\"position: relative; margin-top: 100px\">もっとみるかニャ？</div>")
      div.append buttonAfter
      moreImageAfterElem.find(".img-box").append div
      moreImageAfterElem.find(".img-box").addClass("moreImage")
      owlContainer.append moreImageAfterElem
    return {owlContainer: owlContainer, initialIndex: initialIndex}

  createChild = (childId, childName) ->
    childElem =  $( $("#child-tag-tmpl").clone(true).html() )
    childElem.attr "data-child-id", childId
    text = if childName.length > 10
      childName.substr(0, 10) + "..."
    else
      childName
    childElem.find("a").text text
    return childElem

  getXSRFToken = ->
    cookies = document.cookie.split(/\s*;\s*/)
    for c in cookies
      matched = c.match(/^XSRF-TOKEN=(.*)$/)
      token = matched[1] if matched?
    return token

  hasElem = (data) ->
    for i in data
      return true
    return false

  toggleDisplayedElements = () ->
    if navbarShow
      $(".navbar").hide()
      navbarShow = false
    else
      if navbarFooterHIdeLocked
        $(".navbar:not(\".navbar-footer\")").show()
      else
        $(".navbar").show()
      navbarShow = true

  initializeDisplayedElements = () ->
    navbarFooterHIdeLocked = false
    if navbarShow
      $(".navbar").show()
    else
      $(".navbar").hide()

  replaceToolBoxContent = () ->
    currentEntryIndex = getCurrentEntryIndex()
    elems = $(".img-box")
    if $( $(elems)[ getCurrentPosition() ] ).hasClass "moreImage"
      $(".navbar-footer").hide()
      navbarFooterHIdeLocked = true
      return
    else 
      navbarFooterHIdeLocked = false

    # childの入れ替え
    childContainer = $( $(elems)[currentEntryIndex] ).find(".child-container").clone(true)
    $("#child-tag-container").find("ul").html childContainer.html()

    # コメントの入れ替え
    $("#recent-comment-container").empty()
    comments = window.entryData.entries[currentEntryIndex].comments

    if comments and comments.length > 0
      comments.sort( (a, b) ->
        aCreatedAt = a.created_at
        bCreatedAt = b.created_at
        if aCreatedAt < bCreatedAt
          return 1
        if aCreatedAt > bCreatedAt
          return -1
        return 0
      )
      commentItem = $("<p>")
      commentItem.text comments[0].comment
      $("#recent-comment-container").append commentItem
      commentCount = comments.length
      $("#recent-comment-container").show()
    else
      commentCount = 0
      $("#recent-comment-container").hide()

    # コメント件数の入れ替え
    commentCountText = createCommentNavigation commentCount
    $("#comment-count").text commentCountText

    initializeDisplayedElements()

  createCommentNavigation = (comment_count) ->
    "コメント" + comment_count + "件"

  showNavBarFooter = () ->
    $("#comment-count").on "click", showComments
    $("#comment-edit-icon").on "click", showComments
    $("#child-edit-icon").on "click", editChild
    $("#modal-header").on "click", closeComments
    $(".navbar-footer").show()

  showComments = () ->
    container = $("#all-comment-container")
    comments = window.entryData.entries[ getCurrentEntryIndex() ].comments
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

    container.find("ul").empty()
    container.find("ul").append list
    $(".navbar-footer").addClass("all-comment-container-opened")
    $("#attached-child-tag-container").hide()
    $("#child-edit-container").hide()
    $("#recent-comment-container").hide()
    $("#comment-operation-container").hide()
    $("#comment-input-container").show()
    $("#comment-input-container").find("textarea").focus() if ! comments.length
    $("#modal-header").show()
    container.show()

  closeComments = () ->
    $(".navbar-footer").removeClass("all-comment-container-opened")
    $("#attached-child-tag-container").show()
    $("#child-edit-container").hide()
    $("#recent-comment-container").show()
    $("#comment-operation-container").show()
    $("#child-message-container").hide()
    $("#comment-input-container").hide()
    $("#all-comment-container").hide()
    $("#modal-header").hide()

  editChild = () ->
    $(".navbar-footer").addClass("all-comment-container-opened")
    $("#attached-child-tag-container").hide()
    $("#child-edit-container").show()
    initEditChild()
    $("#recent-comment-container").hide()
    $("#comment-operation-container").hide()
    $("#comment-input-container").hide()
    $("#modal-header").show()

  setUpScreenSize = () ->
    screenHeight = window.innerHeight - 44
    rule = ".all-comment-container-opened { height: " + screenHeight + 'px; }'
    ss = document.styleSheets
    $(ss).each () ->
      if $(this)[0].title == "dynamic"
        idx = $(this)[0].cssRules.length;
        $(this)[0].insertRule rule, idx

  initEditChild = () ->
    currentEntryIndex = getCurrentEntryIndex()
    window.entryData.entries[currentEntryIndex].child or= []
    childHash = {}
    for child in window.entryData.entries[currentEntryIndex].child
      childHash[child.child_id] = true

    $(".child-attach-item").each () ->
      childId = $(this).attr "data-child-id"
      if childHash[childId]
        $(this).find(".child-attached-mark span").show()
      else
        $(this).find(".child-attached-mark span").hide()
    refreshChildAttachedMark()
    $("#child-edit-container").find("ul").listview("refresh")

    # availableなchildがいない場合はその旨のメッセージを表示
    if $(".child-attach-item").length < 1
      $("#child-edit-container,#child-tag-container").hide();
      $("#child-message-container").show()

    adjustHeightOfChildEditContainer()

  adjustHeightOfChildEditContainer = () ->
    # child-tag-containerとchild-edit-containerを合わせて画面いっぱいになるように
    # child-edit-containerの高さを調整
    # innerHeight - modal-header - child-tag-container - 20px(余白)
    navbarHeight       = parseInt $(".navbar.navbar-default").css("height").replace(/px/, ""), 10
    modalHeight        = parseInt $("#modal-header").css("height").replace(/px/, ""), 10
    tagContainerHeight = parseInt $("#child-tag-container").css("height").replace(/px/, ""), 10
    height = innerHeight - navbarHeight - modalHeight - tagContainerHeight - 20
    $("#child-edit-container").css "height", height+"px"

  setupGlobalFooter = () ->
    $("#global-footer").hide()

  setChildAttachList = (related_child) ->
    return if ! related_child || related_child.length < 1

    for child in related_child
      icon_url   = child.icon_url
      child_id   = child.child_id
      child_name = child.child_name

      tmpl = _.template $('#template-child-attach-item').html()
      item = tmpl
        child_icon_url: icon_url
        child_name: child_name,
        child_id: child_id
      itemObj = $(item)
      $("#child-edit-container").find("ul").append itemObj

  attachChildToImage = () ->
    childId   = $(this).attr "data-child-id"
    childName = $(this).find(".child-name").text()
    imageElem = $(".img-box")[ getCurrentEntryIndex() ]
    imageId = $(imageElem).attr("image-id")
    token = getXSRFToken()

    # childタグを表示
    childElem = createChild(childId, childName)
    $("#child-tag-container").find("ul").append childElem if ! alreadyAttachedChild childId

    # $(this)にチェックマークをつける
    $(this).find(".child-attached-mark span").show()

    $.ajax({
      url  : "/image/child/attach.json",
      type : "POST",
      data : {
        "image_id"   : imageId,
        "child_id"   : childId
        "XSRF-TOKEN" : token
      },
      dataType: "json",
      success : (response) ->
        if ! response.rows || response.rows < 1
          removeAttachedChild childId
          refreshChildAttachedMark()
          return

        if addChildToEntryData childId, childName
          # 裏側で保存してるelementにもappendする
          $(imageElem).find(".child-container").append childElem.clone(true)
          refreshChildAttachedMark()
      error   : () ->
        removeAttachedChild childId
        # チェックを外す
        refreshChildAttachedMark()
    })

  hideAttachedChild = (childId) ->
    childTags = $("#child-tag-container").find(".child-tag-li")
    for tag in childTags 
      if childId == $(tag).attr "data-child-id"
        $(tag).hide()

  showAttachedChild = (childId) ->
    childTags = $("#child-tag-container").find(".child-tag-li")
    for tag in childTags 
      if childId == $(tag).attr "data-child-id"
        $(tag).show()

  removeAttachedChild = (childId) ->
    # 表示されているタグを消す
    childTags = $("#child-tag-container").find(".child-tag-li")
    for tag in childTags 
      if childId == $(tag).attr "data-child-id"
        $(tag).remove()

    # 裏で保持してるDOMから削除
    currentEntryIndex = getCurrentEntryIndex()
    $( $(".img-box")[currentEntryIndex] ).find(".child-tag-li").each () ->
      if childId == $(this).attr("data-child-id")
        $(this).remove()

    # entryDataから削除
    childList = window.entryData.entries[currentEntryIndex].child
    length   = childList.length
    for index in [length - 1 .. 0]
      child = childList[index]
      if child.child_id == childId
        childList.splice index, 1

  alreadyAttachedChild = (childId) ->
    currentEntryIndex = getCurrentEntryIndex()
    window.entryData.entries[currentEntryIndex].child or= []
    childList = window.entryData.entries[currentEntryIndex].child
    for child, index in childList
      return true if child.child_id == childId

  addChildToEntryData = (childId, childName) ->
    currentEntryIndex = getCurrentEntryIndex()
    window.entryData.entries[currentEntryIndex].child or= []
    return false if alreadyAttachedChild childId
    window.entryData.entries[currentEntryIndex].child.push {"child_id": childId, "child_name": childName}
    return true

  detachChildFromImage = () ->
    childId   = $(this).attr "data-child-id"
    childName = $(this).find(".child-name").text()
    imageElem = $(".img-box")[ getCurrentEntryIndex() ]
    imageId = $(imageElem).attr("image-id")
    token = getXSRFToken()

    # childタグを隠す
    hideAttachedChild childId 

    # $(this)からチェックを外す
    $(this).find(".child-attached-mark span").hide()

    $.ajax({
      url  : "/image/child/detach.json",
      type : "POST",
      data : {
        "image_id"   : imageId,
        "child_id"   : childId
        "XSRF-TOKEN" : token
      },
      dataType: "json",
      success : (response) ->

        if ! response.rows || response.rows < 1
          showAttachedChild childId
        else
          removeAttachedChild childId

        refreshChildAttachedMark()
      error   : () ->
        showAttachedChild childId
        # チェックをつける
        refreshChildAttachedMark()
    })

  refreshChildAttachedMark = () ->
    currentEntryIndex = getCurrentEntryIndex()
    window.entryData.entries[currentEntryIndex].child or= []

    attachedChildren = {}
    for child in window.entryData.entries[currentEntryIndex].child
      childId = child.child_id
      attachedChildren[childId] = true

    $(".child-attach-item").each ()->
      childId = $(this).attr "data-child-id"
      $(this).off "click"
      if attachedChildren[childId]
        $(this).find(".child-attached-mark span").show()
        $(this).on "click", detachChildFromImage
      else
        $(this).on "click", attachChildToImage

  showCarousel = (params, addOnCallback) ->
    if params.offset
      offset = params.offset
      initial = "min"
    else if params.minIndex
      if params.minIndex <= 10
        offset = 0
        initial = "min"
      else
        offset = params.minIndex - 10
        initial = "max"
    else if params.maxIndex
      initial = "min"
      offset = params.maxIndex + 1
    else
      return

    getData offset, initial, addOnCallback

  getCurrentEntryIndex = () ->
    position = parseInt owlObject.currentPosition(), 10
    if $( $(".img-box")[0] ).hasClass "moreImage"
      position = position - 1
    return position

  getCurrentPosition = () ->
    return parseInt owlObject.currentPosition(), 10

window.util ||= {}
window.util.showImageDetail = showImageDetail
