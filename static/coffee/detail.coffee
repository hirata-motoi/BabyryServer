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
    data = getData()
    owlContainer = $(".owl-carousel").clone(true)
    owlContainer.addClass("displayed")

    # create new contents
    for i in [0 .. data.row_count - 1]

      if data.list[i]
        image_url = data.list[i].image_url
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
          $.ajax("/entry/search.json", {
            processData: false,
            contentType: false,
            data: {
              "page": currentPageNo + 1,
              "count": count,
            },
            dataType: 'json',
            success: showEntries,
            error: showErrorMessage
          })
        else
          window.console.log "shouldPreLoad is false"

    });
  )

  shouldPreLoad = (num) ->
    owl = $(".owl-carousel").data('owlCarousel')
    window.console.log "currentPosition : " + owl.currentPosition()
    # TODO improve
    return if entryIdsInArray.length < owl.currentPosition() + num then true else false

  getData = () ->
    list = $.parseJSON( $("#data-json").attr("data-json") )
    return { list: list, row_count: 100 }

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
    return if response.data.length < 1

    owl = $(".owl-carousel").data('owlCarousel')
    unloadedElems = $(".unloaded");
    for elem, i in unloadedElems
        if response.data[i]
          image_url = response.data[i].fullsize_image_url
          elem.find(".img-box img").attr("src", image_url)
          elem.find(".loading").removeClass("loading")
          entryIdsInArray.push response.data[i].image_id
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

