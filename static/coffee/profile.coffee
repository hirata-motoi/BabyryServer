if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->

window.target_child_id
window.child_data = []
window.is_icon_changed = 0
window.new_icon

$ ->
  getXSRFToken = ->
    cookies = document.cookie.split(/\s*;\s*/)
    for c in cookies
      matched = c.match(/^XSRF-TOKEN=(.*)$/)
      token = matched[1] if matched?
    return token

  tmpl_user = _.template $('#template-user-profile').html()
  tmpl_child = _.template $('#template-child-profile').html()
  tmpl_new_child = _.template $('#template-new-child-profile').html()
  grid_user = $('.user-timeline').get 0
  grid_child = $('.child-timeline').get 0

  # ユーザープロフィール取得
  $.ajax {
    url : '/profile/get.json',
    success : (data) ->
      # ユーザーカラム作成
      user_item = []
      user_item.push document.createElement('article')
      salvattore.append_elements grid_user, user_item
      user_item[0].outerHTML = tmpl_user {
        url: data.icon_image_url,
        name: data.user_name,
      }

      # こどもカラム作成
      child_item = []
      for i in [0 .. data.child.length]
        child_item.push document.createElement('article')
      salvattore.append_elements grid_child, child_item

      # 既存こどもカラム
      if data.child.length > 0
        for i in [0 .. data.child.length - 1]
          child_item[i].outerHTML = tmpl_child {
            name: data.child[i].child_name
            id: data.child[i].child_id
            url: data.child[i].child_icon_url
            birth_year: data.child[i].child_birthday_year
            birth_month: data.child[i].child_birthday_month
            birth_day: data.child[i].child_birthday_day
          }
          window.child_data[data.child[i].child_id] = data.child[i]
          $("#child_edit_button_" + data.child[i].child_id).on 'click', (e) ->
            window.target_child_id = $(this).attr("child_id")
            showEditChildModal(e)

      # 新規こどもカラム
      child_item[data.child.length].outerHTML = tmpl_new_child {
      }
      $("#add-new-child-pannel").on 'click', (e) ->
        window.target_child_id = ""
        showEditChildModal(e)
    error: () ->
      window.console.log "error"
  }

  # こども編集モーダル
  showEditChildModal = (e) ->
    e.stopPropagation()
    $("#editChildModal").modal {
      "backdrop": true
    }
    if window.target_child_id == ""
      $("#child_modal_child_name").attr("value", "")
      $("#child_modal_child_icon").attr("src", "/static/img/160x160.png")
    else
      data = window.child_data[window.target_child_id]
      $("#child_modal_child_name").attr("value", data.child_name)
      $("#child_modal_child_icon").attr("src", data.child_icon_url)

    time = new Date
    year = time.getFullYear()
    for i in [2005 .. year]
      $('#child_birthday_year').append '<option value="' + i + '">' + i + '</option>'
    for i in [1 .. 12]
      if i < 10
        $('#child_birthday_month').append '<option value="0' + i + '">' + i + '</option>'
      else
        $('#child_birthday_month').append '<option value="' + i + '">' + i + '</option>'
    for i in [1 .. 31]
      if i < 10
        $('#child_birthday_day').append '<option value="0' + i + '">' + i + '</option>'
      else
        $('#child_birthday_day').append '<option value="' + i + '">' + i + '</option>'
    if window.target_child_id != ""
      $("#child_birthday_year").val(data.child_birthday_year)
      $("#child_birthday_month").val(data.child_birthday_month)
      $("#child_birthday_day").val(data.child_birthday_day)
    else
      $("#child_birthday_year").val("----")
      $("#child_birthday_month").val("--")
      $("#child_birthday_day").val("--")

  # こども消去submit
  $("#child_edit_delete").on 'click', (e) ->
    token = getXSRFToken()
    if window.target_child_id != ""
      $.ajax({
        "type": "post",
        "url" : "/profile/delete_child.json",
        "data": {
          "child_id": window.target_child_id,
          "XSRF-TOKEN": token
        },
        "dataType": "json",
        "success": () ->
          location.reload true
        "error": () ->
      })

  # 編集submit
  $("#child_edit_submit").on 'click', (e) ->
    token = getXSRFToken()
    if window.target_child_id == ""
      $.ajax({
        "type": "post",
        "url" : "/profile/add_child.json",
        "data": {
          "child_name": $("#child_modal_child_name").val(),
          "birth_year": $("#child_birthday_year").val(),
          "birth_month": $("#child_birthday_month").val(),
          "birth_day": $("#child_birthday_day").val(),
          "XSRF-TOKEN": token
        },
        "dataType": "json",
        "success": (response) ->
          if window.is_icon_changed == 1
            window.target_child_id = response.id
            uploadChildIcon window.new_icon
          else
            location.reload true
        "error": () ->
      })
    else
      $.ajax({
        "type": "post",
        "url" : "/profile/edit_child.json",
        "data": {
          "child_id": window.target_child_id,
          "child_name": $("#child_modal_child_name").val(),
          "birth_year": $("#child_birthday_year").val(),
          "birth_month": $("#child_birthday_month").val(),
          "birth_day": $("#child_birthday_day").val(),
          "XSRF-TOKEN": token
        },
        "dataType": "json",
        "success": () ->
          if window.is_icon_changed == 1
            uploadChildIcon window.new_icon
          else
            location.reload true
        "error": () ->
      })

  # icon変える
  $("#child_modal_change_icon").on 'click', () ->
    $("#image-post-form").find("[type=file]").trigger("click")
    return false

  $form = $("#image-post-form")
  $form.find("[type=file]").on "change", () ->
    window.is_icon_changed = 1
    window.console.log "file changed"

    $("#child_modal_child_icon").attr "src", "/static/img/ajax-loader.gif"

    fd = new FormData( $form[0] )
    $.ajax( $form.attr("action"), {
      type: 'post',
      processData: false,
      contentType: false,
      data: fd,
      dataType: 'json',
      success: (data) ->
        window.console.log data
        window.new_icon = data.image_tmp_name
        $("#child_modal_child_icon").attr "src", data.image_tmp_url
      error: showErrorMessage
    })
    return false

  showErrorMessage = (xhr, textStatus, errorThrown) ->
    window.console.log "error"
    window.console.log xhr.responseText
    # TODO show error message
    window.alert xhr.responseText

  uploadChildIcon = (icon) ->
    token = getXSRFToken()
    window.console.log window.target_child_id
    $.ajax "/image/web/submit.json", {
      type: "post",
      data: {
        "shared_user_ids": [],
        "image_tmp_names": [icon],
        "child_id": window.target_child_id,
        "XSRF-TOKEN": token
      },
      dataType: 'json',
      success: () ->
        window.console.log 'icon submitted'
        location.reload true
      error: showErrorMessage
    }
