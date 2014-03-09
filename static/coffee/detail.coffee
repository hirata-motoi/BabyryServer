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

entryIdsInArray = []
loadingFlg = false
$( () ->

  $(".img-thumbnail").on("click", () ->
    imageId   = $(this).parents(".item").attr("image_id")
    data = getData preserveResponseData, showErrorMessage, true
  
    # setup stampsByImagePosition
    upsertStampsByImagePosition data.list

    owlContainer = $(".owl-carousel").clone(true)
    owlContainer.addClass("displayed")

    # create new contents
    for i in [0 .. data.found_row_count - 1]

      if data.list[i]
        image_url = data.list[i].fullsize_image_url
        entryIdsInArray.push data.list[i].image_id
        stamps = data.list[i].stamps
        image_id = data.list[i].image_id
      else 
        image_url = ""
        image_id  = ""

      $elem = createImageBox image_url, image_id
      owlContainer.append $elem
      initialIndex = i if data.list[i] and data.list[i].image_id == imageId
      
      if stamps and stamps.length > 0
        stampList = []
        for stampInfo, n in stamps
          stampElem = $("<a>")
          stampElem.addClass("stamp")

          stampImage = $("<img>")
          stampImage.addClass("stamp-icon")
          stampImage.attr("src", stampInfo.icon_url)
          stampElem.append stampImage
          $elem.find(".stamp-container").append stampElem

    # replace html of container
    $(".dynamic-container").html( owlContainer )

    # set carousel
    $(".owl-carousel.displayed").owlCarousel({
      items: 1,
      scrollPerPage: true,
      beforeInit: () ->
        # タップされた画像を初期位置へ
        #owl = $(".owl-carousel").data('owlCarousel')
        #owl.jumpTo(initialIndex)
      beforeMove: () ->
      afterMove: () ->
        if shouldPreLoad(5)
          return if loadingFlg

          # 前回取得したページno
          currentPageNo = 1

          # いくつentryを取得するか
          count = 10

          # とりあえず1つぐるぐるをだしておく
          showLoadingImage()

          # loading flg
          loadingFlg = true

          # ajax
          ###
          $.ajax({
            "url": "/entry/search.json",
            "processData": true,
            "contentType": false,
            "data": {
              "page": currentPageNo + 1,
              "count": count,
            },
            "dataType": 'json',
            "success": showEntries,
            "error": showErrorMessage
          })
          ###
          getData showEntries, showErrorMessage, false
    });
    $(".stamp-attach-icon").on "click", attachStamp
  )

  shouldPreLoad = (num) ->
    owl = $(".owl-carousel").data('owlCarousel')
    # TODO improve
    return if entryIdsInArray.length < owl.currentPosition() + num then true else false

  preserveResponseData = (response) ->
    window.entryData.entries.push entry for entry in response.data.entries
    window.entryData.metadata = response.metadata

  getData = (successCallback, errorCallback, tempNotAsyncFlg) ->

    nextPage = if window.entryData.metadata.page then parseInt(window.entryData.metadata.page, 10) + 1 else 1
    countPerPage = window.entryData.metadata.count || 10
    # ajax
    $.ajax({
      "url" : "/entry/search.json",
      "async": !tempNotAsyncFlg, # temporary
      "processData": true,
      "contentType": false,
      "data": {
        "page": nextPage,
        "count": countPerPage
      },
      "dataType": 'json',
      "success": successCallback
      "error": errorCallback
    })
    return {
      list: window.entryData.entries,
      found_row_count: window.entryData.metadata.found_row_count
    }


  createImageBox = (image_url, image_id) ->
    tmpl = $("#item-tmpl").clone(true)
    owlElem = $(tmpl)
    owlElem.find(".img-box").attr("image-id", image_id)
    owlElem.find(".img-box img").attr("src", image_url)
    owlElem.attr("id", "")
    owlElem.addClass("unloaded") if !image_url
    owlElem.show()
    return owlElem

  showLoadingImage = () ->
    $(".unloadedElems").first().find(".img-box img").attr("src", "/static/img/ajax-loader.gif")

  showErrorMessage = () ->
    # TODO implement

  showEntries = (response) ->
    return if response.data.entries.length < 1

    preserveResponseData response

    owl = $(".owl-carousel").data('owlCarousel')
    unloadedElems = $(".unloaded");
    for elem, i in unloadedElems
        if response.data.entries[i]
          image_url = response.data.entries[i].fullsize_image_url
          $(elem).find(".img-box img").attr("src", image_url)
          $(elem).find(".loading").removeClass("loading")
          $(elem).removeClass("unloaded")
          entryIdsInArray.push response.data.entries[i].image_id
        else
          loadingFlg = false
          break
    loadingFlg = false


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
    owl = $(".owl-carousel").data('owlCarousel')
    currentPosition = owl.currentPosition()

    # 既にattach済なら何もしない
    return if alreadyAttachedStamp stampId, currentPosition

    stampHash = getStampHash()
    stampIconUrl = stampHash[stampId].icon_url
    targetImgBox = $(".img-box")[currentPosition]
    imageId = $(".img-box").attr("image-id")

    # stampのaを作ってappend
    stampElem = $("<a>")
    stampElem.addClass "stamp"
    #stampElem.attr "href", "#stampAttachModal"
    #stampElem.attr "data-toggle", "modal"
    #stampElem.attr "data-backdrop", "true"

    stampImage = $("<img>")
    stampImage.addClass "stamp-icon"
    stampImage.attr "src", stampIconUrl
    stampElem.append stampImage
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
    window.stampData = response.data
    setStampAttachList()

    
)
