if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->
$ ->


###
set event to click each image
this part will be replaced by methods in entries.coffee
###



entryIdsInArray = []
loadingFlg = false
$( () ->
  $(".img-thumbnail").on("click", () ->
    imageId   = $(this).parents(".item").attr("image_id")
    data = getData preserveResponseData, showErrorMessage, true
    window.console.log data.list
    owlContainer = $(".owl-carousel").clone(true)
    owlContainer.addClass("displayed")

    # create new contents
    for i in [0 .. data.found_row_count - 1]

      if data.list[i]
        window.console.log data.list[i]
        image_url = data.list[i].fullsize_image_url
        entryIdsInArray.push data.list[i].image_id
      else 
        image_url = ""

      elem = createImageBox(image_url)
      owlContainer.append(elem)
      initialIndex = i if data.list[i] and data.list[i].image_id == imageId
      
    window.console.log initialIndex

    # replace html of container
    $(".dynamic-container").html( owlContainer )

    # set carousel
    $(".owl-carousel.displayed").owlCarousel({
      items: 1,
      scrollPerPage: true,
      beforeInit: () ->
        # タップされた画像を初期位置へ
        #owl = $(".owl-carousel").data('owlCarousel')
        #owl.jumpTo()
      beforeMove: () ->
      afterMove: () ->
        if shouldPreLoad(5)
          window.console.log "shouldPreLoad is true"
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
          $.ajax("/entry/search.json", {
            processData: true,
            contentType: false,
            data: {
              "page": currentPageNo + 1,
              "count": count,
            },
            dataType: 'json',
            success: showEntries,
            error: showErrorMessage
          })
          ###
          getData showEntries, showErrorMessage, false
        else
          window.console.log "shouldPreLoad is false"

    });
  )

  shouldPreLoad = (num) ->
    owl = $(".owl-carousel").data('owlCarousel')
    window.console.log "currentPosition : " + owl.currentPosition()
    # TODO improve
    return if entryIdsInArray.length < owl.currentPosition() + num then true else false

  preserveResponseData = (response) ->
    window.entryData or= {}
    window.entryData.entries or= []
    window.entryData.entries.push entry for entry in response.data.entries
    window.entryData.metadata = response.metadata

  getData = (successCallback, errorCallback, tempNotAsyncFlg) ->
    window.entryData or= {}
    window.entryData.metadata or= {}

    nextPage = if window.entryData.metadata.page then parseInt(window.entryData.metadata.page, 10) + 1 else 1
    countPerPage = window.entryData.metadata.count || 10
    # ajax
    $.ajax("/entry/search.json", {
      async: !tempNotAsyncFlg, # temporary
      processData: true,
      contentType: false,
      data: {
        "page": nextPage,
        "count": countPerPage
      },
      dataType: 'json',
      success: successCallback
      error: errorCallback
    })
    return {
      list: window.entryData.entries,
      found_row_count: window.entryData.metadata.found_row_count
    }


  createImageBox = (image_url) ->
    tmpl = $("#item-tmpl").clone(true)
    owlElem = $(tmpl)
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
    window.console.log response
    return if response.data.entries.length < 1

    preserveResponseData response

    owl = $(".owl-carousel").data('owlCarousel')
    unloadedElems = $(".unloaded");
    for elem, i in unloadedElems
        if response.data.entries[i]
          window.console.log response.data.entries[i]
          window.console.log elem
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

 )

