if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->

window.target_child_id
window.user_data = []
window.is_icon_changed = 0
window.new_icon
window.view_other_profile = 0
window.temp_url = ""

$ ->
  getXSRFToken = ->
    cookies = document.cookie.split(/\s*;\s*/)
    for c in cookies
      matched = c.match(/^XSRF-TOKEN=(.*)$/)
      token = matched[1] if matched?
    return token

  tmpl_user = _.template $('#template-user-profile').html()
  tmpl_relatives = _.template $('#template-relatives-profile').html()
  tmpl_child = _.template $('#template-child-profile').html()
  tmpl_new_child = _.template $('#template-new-child-profile').html()
  grid_user = $('.user-timeline').get 0
  grid_relatives = $('.relatives-timeline').get 0
  grid_child = $('.child-timeline').get 0

  profile_get_url = "/profile/get.json"
  if $("#profile_js").attr("target_user_id")
    profile_get_url = "/profile/get.json?target_user_id=" + $("#profile_js").attr("target_user_id")
    window.view_other_profile = 1

  # ユーザープロフィール取得
  $.ajax {
    url : profile_get_url,
    success : (data) ->
      # ユーザーカラム作成
      window.user_data = data
      visibility = "hidden"
      if data.accessed_user_id == data.user_id
        visibility = "visible"
      HTML = tmpl_user {
        url: data.icon_image_url,
        name: data.user_name,
        id: data.user_id,
        edit_visibility: visibility,
      }
      $('#profile_user').append HTML
      $("#user_edit_button_" + data.user_id).on 'click', (e) ->
        showEditUserModal(e)

      # relativesカラム作成
      if data.relatives.length > 0
        for i in [0 .. data.relatives.length - 1]
          if data.relatives[i].relative_name == ""
            data.relatives[i].relative_name = "名無し"
          HTML = tmpl_relatives {
            url: data.relatives[i].relative_icon_url,
            name: data.relatives[i].relative_name,
            id: data.relatives[i].relative_id,
          }
          $('#profile_friend').append HTML
          $("#relative_panel_" + data.relatives[i].relative_id).on 'click', () ->
            location.href = "/profile?target_user_id=" + $(this).attr("relative_id")

      # こどもカラム作成

      # 新規こどもカラム
      if window.view_other_profile != 1
        HTML = tmpl_new_child {}
        $('#profile_child').append HTML
        $("#add-new-child-pannel").on 'click', (e) ->
          window.target_child_id = ""
          showEditChildModal(e)

      # 既存こどもカラム
      if data.child.length > 0
        for i in [0 .. data.child.length - 1]
          visibility = "hidden"
          if data.child[i].created_by == data.accessed_user_id
            visibility = "visible"
          HTML = tmpl_child {
            edit_visibility: visibility
            name: data.child[i].child_name
            id: data.child[i].child_id
            url: data.child[i].child_icon_url
            birth_year: data.child[i].child_birthday_year
            birth_month: data.child[i].child_birthday_month
            birth_day: data.child[i].child_birthday_day
          }
          $('#profile_child').append HTML
          $("#child_edit_button_" + data.child[i].child_id).on 'click', (e) ->
            window.target_child_id = $(this).attr("child_id")
            showEditChildModal(e)

    error: () ->
      window.console.log "error"
  }

  # ユーザー編集モーダル
  showEditUserModal = (e) ->
    e.stopPropagation()
    $("#editUserModal").modal {
      "backdrop": true
    }
    $("#user_modal_user_name").attr("value", $('#user_profile_user_name').text())
    $("#user_modal_user_icon").attr("src", $('#user_profile_user_icon').attr("src"))

  # こども編集モーダル
  showEditChildModal = (e) ->
    e.stopPropagation()
    $("#editChildModal").modal {
      "backdrop": true
    }
    $("#child_modal_child_name").attr("value", $('#user_profile_child_name_' + window.target_child_id).text())
    $("#child_modal_child_icon").attr("src", $('#user_profile_child_icon_' + window.target_child_id).attr("src"))

    options = $("#child_birthday_year").find("option")
    if $(options).length < 2
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

    $("#child_birthday_year").val $('#user_profile_birth_year_' + window.target_child_id).text()
    elems = $("#child_birthday_year").find("option")
    for elem in elems
      if $(elem).attr('value') == $('#user_profile_birth_year_' + window.target_child_id).text()
        $(elem).attr 'selected', true
        $(elem).trigger "change"
        break
    $("#child_birthday_month").val $('#user_profile_birth_month_' + window.target_child_id).text()
    elems = $("#child_birthday_month").find("option")
    for elem in elems
      if $(elem).attr('value') == $('#user_profile_birth_month_' + window.target_child_id).text()
        $(elem).attr 'selected', true
        $(elem).trigger "change"
        break
    $("#child_birthday_day").val $('#user_profile_birth_day_' + window.target_child_id).text()
    elems = $("#child_birthday_day").find("option")
    for elem in elems
      if $(elem).attr('value') == $('#user_profile_birth_day_' + window.target_child_id).text()
        $(elem).attr 'selected', true
        $(elem).trigger "change"
        break

  # ユーザー編集submit
  $("#user_edit_submit").on 'click', (e) ->
    token = getXSRFToken()
    $.ajax({
      "type": "post",
      "url" : "/profile/edit_name.json",
      "data": {
        "user_id": window.user_data.user_id,
        "user_name": $("#user_modal_user_name").val(),
        "XSRF-TOKEN": token
      },
      "dataType": "json",
      "success": () ->
        if window.is_icon_changed == 1
          uploadUserIcon window.new_icon
        $('#user_profile_user_name').text $("#user_modal_user_name").val()
      "error": () ->
    })

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
          $('#item_user_profile_child_icon_' + window.target_child_id).remove()
        "error": () ->
      })

  # こども編集submit
  $("#child_edit_submit").on 'click', (e) ->
    token = getXSRFToken()
    # child_idが空 = 新規child
    if window.target_child_id == ""
      window.temp_url = ""
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
            window.new_icon = ""
          # DOM追加
          HTML = tmpl_child {
            edit_visibility: "visible"
            name: $("#child_modal_child_name").val()
            id: response.id
            url: window.new_icon
            birth_year: $("#child_birthday_year").val()
            birth_month: $("#child_birthday_month").val()
            birth_day: $("#child_birthday_day").val()
          }
          $('#profile_child').append HTML
          $("#child_edit_button_" + response.id).on 'click', (e) ->
            window.target_child_id = $(this).attr("child_id")
            showEditChildModal(e)
        "error": () ->
      })
    # 既存の子供の更新
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
          # 名前と生年月日更新
          $('#user_profile_child_name_' + window.target_child_id).text $("#child_modal_child_name").val() 
          $('#user_profile_birth_year_' + window.target_child_id).text $("#child_birthday_year").val()
          $('#user_profile_birth_month_' + window.target_child_id).text $("#child_birthday_month").val()
          $('#user_profile_birth_day_' + window.target_child_id).text $("#child_birthday_day").val()
        "error": () ->
      })

  # user icon変える (userとchildで冗長かも)
  $(".user_modal_change_icon").on 'click', () ->
    $("#user-image-post-form").find("[type=file]").trigger("click")
    return false

  $user_form = $("#user-image-post-form")
  $user_form.find("[type=file]").on "change", () ->
    window.is_icon_changed = 1
    window.console.log "file changed"

    $("#user_modal_user_icon").attr "src", "/static/img/ajax-loader.gif"

    fd = new FormData( $user_form[0] )
    $.ajax( $user_form.attr("action"), {
      type: 'post',
      processData: false,
      contentType: false,
      data: fd,
      dataType: 'json',
      success: (data) ->
        window.console.log data
        window.new_icon = data.image_tmp_name
        $("#user_modal_user_icon").attr "src", data.image_tmp_url
        window.temp_url = data.image_tmp_url
      error: showErrorMessage
    })
    return false

  # child icon変える
  $(".child_modal_change_icon").on 'click', () ->
    $("#child-image-post-form").find("[type=file]").trigger("click")
    return false

  $child_form = $("#child-image-post-form")
  $child_form.find("[type=file]").on "change", () ->
    window.is_icon_changed = 1
    window.console.log "file changed"

    $("#child_modal_child_icon").attr "src", "/static/img/ajax-loader.gif"

    fd = new FormData( $child_form[0] )
    $.ajax( $child_form.attr("action"), {
      type: 'post',
      processData: false,
      contentType: false,
      data: fd,
      dataType: 'json',
      success: (data) ->
        window.console.log data
        window.new_icon = data.image_tmp_name
        $("#child_modal_child_icon").attr "src", data.image_tmp_url
        window.temp_url = data.image_tmp_url
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
        $('#user_profile_child_icon_' + window.target_child_id).attr("src", window.temp_url)
      error: showErrorMessage
    }

  uploadUserIcon = (icon) ->
    token = getXSRFToken()
    window.console.log window.user_data.user_id
    $.ajax "/image/web/submit.json", {
      type: "post",
      data: {
        "shared_user_ids": [],
        "image_tmp_names": [icon],
        "is_icon": "1",
        "XSRF-TOKEN": token
      },
      dataType: 'json',
      success: () ->
        window.console.log 'icon submitted'
        $('#user_profile_user_icon').attr("src", window.temp_url)
      error: showErrorMessage
    }
