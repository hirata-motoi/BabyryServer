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
window.entryData.related_children or= {}
window.childrenData or= {}
window.child_ids or = []

window.entryIdsInArray = []
window.loadingFlg = false
window.displayedElementsFlg = true
owlObject = undefined
defaultTextareaHeight = "30px"
innerWidth  = 0
innerHeight = 0

showImageDetail = () ->
  $(".img-thumbnail").on("click", () ->
    # styleに画面の大きさを設定
    setUpScreenSize()

    setupGlobalFooter()

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

    # create new contents
    ret = createOwlElements tappedEntryIndex
    owlContainer = ret.owlContainer
    initialIndex = ret.initialIndex

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
      afterMove: () ->
        currentPosition = owlObject.currentPosition()
        imageBoxes = $(".img-box")
        replaceToolBoxContent()
#        if shouldPreLoad(5)
#          return if window.loadingFlg

          # 前回取得したページno
#          currentPageNo = 1

          # いくつentryを取得するか
#          count = 10

          # とりあえず1つぐるぐるをだしておく
#          showLoadingImage()

          # loading flg
#          loadingFlg = true

          # ajax
#getData showEntries, showErrorMessage
    })

    # owlObjectをメモリに保持
    owlObject = $(".owl-carousel.displayed").data("owlCarousel")

    # タップされた画像を初期位置へ
    owlObject.jumpTo(initialIndex)

    window.util.hidePageLoading()

    # footer
    showNavBarFooter()

    # child
    setChildAttachList(data.related_children)
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
    window.entryData.entries  =  response.data.entries
    window.entryData.metadata = response.metadata
    window.entryData.related_children = response.related_children

  pickData = () ->
    return {
      list: window.entryData.entries,
      found_row_count: window.entryData.metadata.found_row_count,
      related_children: window.entryData.related_children
    }

  getData = (offset, initial, successCallback, errorCallback) ->
    nextPage = if window.entryData.metadata.page then parseInt(window.entryData.metadata.page, 10) + 1 else 1
    countPerPage = window.entryData.metadata.count || 10
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
        successCallback response, initial
      "error"   : errorCallback
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

  showEntries = (response, initial) ->
    return if response.data.entries.length < 1

    preserveResponseData response

    initialIndex = if initial == "max"
      response.data.entries.length - 1
    else
      0

    ret = createOwlElements initialIndex
    owlContainer = ret.owlContainer
    initialIndex = ret.initialIndex

    $(".dynamic-container").html( owlContainer )

    # set carousel
    $(".owl-carousel.displayed").owlCarousel({
      items: 1,
      pagination: false,
      scrollPerPage: true,
      afterMove: () ->
        replaceToolBoxContent()
    })

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
    # childの入れ替え
    childContainer = $( $(elems)[currentPosition] ).find(".child-container").clone(true)
    $("#child-tag-container").find("ul").html childContainer.html()

    # コメントの入れ替え
    $("#recent-comment-container").empty()
    comments = window.entryData.entries[currentPosition].comments

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
    currentPosition = parseInt owlObject.currentPosition(), 10
    window.entryData.entries[currentPosition].child or= []
    childHash = {}
    for child in window.entryData.entries[currentPosition].child
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
      $("#child-message-container").show();

      

  setupGlobalFooter = () ->
    $("#global-footer").hide()

  setChildAttachList = (related_children) ->
    return if ! related_children || related_children.length < 1

    for child in related_children
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
    currentPosition = owlObject.currentPosition()
    imageElem = $(".img-box")[currentPosition]
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
    currentPosition = owlObject.currentPosition()
    $( $(".img-box")[currentPosition] ).find(".child-tag-li").each () ->
      if childId == $(this).attr("data-child-id")
        $(this).remove()

    # entryDataから削除
    children = window.entryData.entries[currentPosition].child
    length   = children.length
    for index in [length - 1 .. 0]
      child = children[index]
      if child.child_id == childId
        children.splice index, 1

  alreadyAttachedChild = (childId) ->
    currentPosition = owlObject.currentPosition()
    window.entryData.entries[currentPosition].child or= []
    children = window.entryData.entries[currentPosition].child
    for child, index in children
      return true if child.child_id == childId

  addChildToEntryData = (childId, childName) ->
    currentPosition = owlObject.currentPosition()
    window.entryData.entries[currentPosition].child or= []
    return false if alreadyAttachedChild childId
    window.entryData.entries[currentPosition].child.push {"child_id": childId, "child_name": childName}
    return true

  detachChildFromImage = () ->
    childId   = $(this).attr "data-child-id"
    childName = $(this).find(".child-name").text()
    currentPosition = owlObject.currentPosition()
    imageElem = $(".img-box")[currentPosition]
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
          refreshChildAttachedMark()
          return

        removeAttachedChild childId
        refreshChildAttachedMark()
      error   : () ->
        showAttachedChild childId
        # チェックをつける
        refreshChildAttachedMark()
    })

  refreshChildAttachedMark = () ->
    currentPosition = owlObject.currentPosition()
    window.entryData.entries[currentPosition].child or= []

    attachedChildren = {}
    for child in window.entryData.entries[currentPosition].child
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

  lazyLoad = (imageElem) ->
    imageUrl = $(imageElem).attr("data-image-url")
    window.console.log "imageUrl : " + imageUrl
    $(imageElem).css "background-image",  "url(" + imageUrl + ")"
  
  lazyRelease = (imageElems) ->
    for elem in imageElems
      window.console.log "release imageElem : " + elem
      $(elem).css "background-image",  ""

  releaseTargetElems = (imageBoxes, currentPosition) ->
    length = imageBoxes.length

    maxIndex = length - 1
    minIndex = 0
    targetOverIndex  = parseInt(currentPosition, 10) + 3
    targetUnderIndex = parseInt(currentPosition, 10) - 3

    window.console.log "targetOverIndex : " + targetOverIndex

    targetElems = []
    if targetOverIndex <= maxIndex
      targetElems.push imageBoxes[ targetOverIndex ]
    if targetUnderIndex >= minIndex
      targetElems.push imageBoxes[ targetUnderIndex ]
    return targetElems 

  createOwlElements = (tappedEntryIndex) ->
    data  = pickData()
    count = data.found_row_count
    if count <= 10
      minIndex = 0
      maxIndex = data.found_row_count - 1
      initialIndex = tappedEntryIndex
      moreImageBefore = false
      moreImageAfter  = false
    else if tappedEntryIndex < 5
      minIndex = 0
      maxIndex = minIndex + 9
      initialIndex = tappedEntryIndex
      moreImageBefore = false
      moreImageAfter  = true
    else if count - 6 <= tappedEntryIndex
      maxIndex = count - 1
      minIndex = maxIndex - 9
      initialIndex = tappedEntryIndex - 5 + 1 # 1 : moreImageBeforeの分
      moreImageBefore = true
      moreImageAfter  = false
    else
      initialIndex = 4 + 1 # 1 : moreImageBeforeの分
      minIndex = tappedEntryIndex - 4
      maxIndex = minIndex + 9
      moreImageBefore = true
      moreImageAfter  = true
      
    owlContainer = $(".owl-carousel.template").clone(true)
    owlContainer.removeClass("template")
    owlContainer.addClass("displayed")

    if moreImageBefore
      moreImageBeforeElem = createImageBox "/static/img/stamp/icon/1.jpeg", 0, 0, innerWidth, innerHeight
      buttonBefore = $("<button>").text "more images"
      buttonBefore.on "click", () ->
        replaceCarousel {minIndex: minIndex}
      moreImageBeforeElem.find(".img-box").append buttonBefore
      owlContainer.append moreImageBeforeElem
    for i in [minIndex..maxIndex]
      if data.list[i]
        image_url = data.list[i].fullsize_image_url
        window.entryIdsInArray = [] # initialize
        window.entryIdsInArray.push data.list[i].image_id
        childList = data.list[i].child
        image_id = data.list[i].image_id
        comment_count = data.list[i].comments.length
        $elem = createImageBox image_url, image_id, comment_count, innerWidth, innerHeight
        owlContainer.append $elem

        if childList
          for childInfo, n in childList
            childElem = createChild(childInfo.child_id, childInfo.child_name)
            $elem.find(".child-container").append childElem
        $elem.find(".child-container").hide()
    if moreImageAfter
      moreImageAfterElem = createImageBox "/static/img/stamp/icon/1.jpeg", 0, 0, innerWidth, innerHeight
      buttonAfter = $("<button>").text "more images"
      window.console.log buttonAfter
      buttonAfter.on "click", () ->
        replaceCarousel {maxIndex: maxIndex}
      moreImageAfterElem.find(".img-box").append buttonAfter
      owlContainer.append moreImageAfterElem
    return {initialIndex: initialIndex, owlContainer: owlContainer}

  replaceCarousel = (params) ->
    if params.minIndex
      initial = "max"
      if params.minIndex <= 10
        offset = 0
      else
        offset = params.minIndex - 10
    else if params.maxIndex
      initial = "min"
      offset = params.maxIndex + 1
    else
      return

    # getDataする
    getData offset, initial, showEntries, showErrorMessage


window.util ||= {}
window.util.showImageDetail = showImageDetail
