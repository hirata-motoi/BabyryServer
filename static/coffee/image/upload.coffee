if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->
$ ->

showLoadingImage = () ->
  box = $("<div>").addClass "js-uploaded-image-box"
  box.css "display", "table-cell"
  box.css "width", "100"
  box.css "height", "100"
  box.css "text-align", "center"
  box.css "vertical-align", "middle"
  box.css "padding-left", "6px"
  box.css "padding-right", "6px"

  innerBox = $("<div>")
  innerBox.css "display", "table-cell"
  innerBox.css "width", "88"
  innerBox.css "height", "88"
  innerBox.css "text-align", "center"
  innerBox.css "vertical-align", "middle"

  innerBox.css "border", "solid 1px gray"
  innerBox.css "padding", "1px"
  innerBox.css "margin", "2px"
  innerBox.addClass "inner-box"

  image = $("<img>")
  image.attr "src", "/static/img/ajax-loader.gif"

  # TODO trim 
  image.css "width", "30"
  image.css "height", "30"

  innerBox.append image
  box.append innerBox
  $(".js-image-container").append box
  return box

submit = () ->
  filenames = []
  $(".js-uploaded-image-box").each( () ->
    filenames.push $(this).attr("filename")
  )

  # TODO define common method in main.js
  token = getXSRFToken() 

  relatives = pickedSharedRelatives()
  targetChild = pickedTargetChild()

  $.ajax( "/image/web/submit.json", {
      type: "post",
      data: {
        "shared_user_ids": relatives,
        "target_child_ids": targetChild,
        "image_tmp_names": filenames,
        "XSRF-TOKEN": token
      },
      dataType: 'json',
      success: redirectToWall,
      error: (xhr) ->
        showErrorMessage xhr,
    }
  )

redirectToWall = (data) ->
  location.href = "/"

showErrorMessage = (xhr, box) ->
  box.remove() if box
  $(".error").show()

getXSRFToken = ->
  cookies = document.cookie.split(/\s*;\s*/)
  for c in cookies
    matched = c.match(/^XSRF-TOKEN=(.*)$/)
    token = matched[1] if matched?
  return token

pickedSharedRelatives = () ->
  relativeIds = for elem in $(".relative-checked-mark.checked")
    $(elem).parent(".relative-list").attr "data-relative-id"

pickedTargetChild = () ->
  childIds = for elem in $(".child-checked-mark.checked")
    $(elem).parent(".child-list").attr "data-child-id"

toggleCheckMark = () ->
  checkedMark = $(this).find(".checked-mark");
  if $(checkedMark).hasClass "checked"
    $(checkedMark).removeClass "checked"
  else
    $(checkedMark).addClass "checked"

openAttachChildToImages = () ->
  window.attachedChildToImages = []
  $("#childModal").modal()

setXSRFTokenToForm = () ->
  token = getXSRFToken
  $("form").each (i, form) ->
    method = $(form).attr "method"
    return if method is "get" or method is "GET"

    $input = $("<input>")
    $input.attr "type", "hidden"
    $input.attr "name", "XSRF-TOKEN"
    $input.attr "value", token

    $(form).append $input

setupImageUpload = () ->
  $form = $("#image-post-form")
  $form.find("[type=file]").on("change", () ->

    $(".error").hide()

    box = showLoadingImage()

    fd = new FormData( $form[0] )
    $.ajax( $form.attr("action"), {
      type: 'post',
      processData: false,
      contentType: false,
      data: fd,
      dataType: 'json',
      success: (data) ->
        box.find("img").attr "src", ""
        box.attr "filename", data.image_tmp_name
        box.find("img").attr "src", data.image_tmp_url
        # TODO trim 
        box.find("img").css "width", "80"
        box.find("img").css "height", "80"
      error: (xhr) ->
        showErrorMessage xhr, box
    })
    return false
  )
  setXSRFTokenToForm()
  $("#image-upload-submit-button").on "click", submit
  $(".relative-list,.child-list").on "click", toggleCheckMark
  $("#image-upload-child-mapping").on "click", openAttachChildToImages

  $("#add-image-icon").on "click", () ->
    $("#image-post-form").find("[type=file]").trigger("click")
    return false

$(document).off "pagechange"
$(document).on "pagechange", setupImageUpload
  
