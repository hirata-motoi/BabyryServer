if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->
$ ->

$("#add-image-icon").on("click", () ->
  $("#image-post-form").find("[type=file]").trigger("click")
  return false
)

$form = $("#image-post-form")
$form.find("[type=file]").on("change", () ->
  window.console.log "file changed"

  fd = new FormData( $form[0] )
  $.ajax( $form.attr("action"), {
    type: 'post',
    processData: false,
    contentType: false,
    data: fd,
    dataType: 'json',
    success: showTmpImage,
    error: showErrorMessage
  })
  return false
)

showTmpImage = (data) ->
  window.console.log data

  box = $("<span>").addClass "js-uploaded-image-box"
  box.attr "filename", data.image_tmp_name

  image = $("<img>")
  image.attr "src", data.image_tmp_url

  # TODO trim 
  image.css "width", "80"
  image.css "height", "80"

  box.append image
  $(".js-image-container").append box

$("#submit-button").on("click", () ->
  filenames = []
  $(".js-uploaded-image-box").each( () ->
    filenames.push $(this).attr("filename")
  )

  # TODO define common method in main.js
  token = getXSRFToken() 

  $.ajax( "/image/web/submit.json", {
      type: "post",
      data: {
        "image_tmp_names": filenames,
        "XSRF-TOKEN": token
      },
      dataType: 'json',
      success: redirectToWall,
      error: showErrorMessage,
    }
  )
)

redirectToWall = (data) ->
  location.href = "/"

showErrorMessage = (xhr, textStatus, errorThrown) ->
  window.console.log xhr.responseText
  # TODO show error message
  window.alert xhr.responseText

getXSRFToken = ->
  cookies = document.cookie.split(/\s*;\s*/)
  for c in cookies
    matched = c.match(/^XSRF-TOKEN=(.*)$/)
    token = matched[1] if matched?
  return token

