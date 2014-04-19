if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->

if window.entryData is "undefined"
  window.entryData = {}

page = 1
count = 10

window.showGroupByModal
window.stamp_ids = []
window.child_ids = []
window.album_attr = []
window.album_key_id = ""
window.profile
stamp_ids_hash = []
child_ids_hash = []

$ ->
  getXSRFToken = ->
    cookies = document.cookie.split(/\s*;\s*/)
    for c in cookies
      matched = c.match(/^XSRF-TOKEN=(.*)$/)
      token = matched[1] if matched?
    return token

  tmpl = _.template $('#template-item').html()
  grid = $('.timeline').get 0

  tmpl_album = _.template $('#template-album').html()
  tmpl_album_edit = _.template $('#template-album-edit').html()
  tmpl_album_element = _.template $('#template-album-element').html()

  # setup groupByIcon
  $("#group_by_stamp").show();
  $("#custom_album").show();

  load_contents = (stamp_ids, child_ids) ->
    $.ajax {
      url : '/entry/search.json',
      dataType: "json",
      traditional: true,
      data: {
        stamp_id: stamp_ids,
        child_id: child_ids,
        count: count,
        page: page
      },
      success : (data) ->
        return if data.data.entries.length < 1
        item = []
        for i in [0 .. data.data.entries.length - 1]
          item.push document.createElement('article')

        salvattore.append_elements grid, item
        for i in [0 .. data.data.entries.length - 1]
          item[i].outerHTML = tmpl {
            stamp_num: data.data.entries[i].stamps.length,
            comment_num: data.data.entries[i].comments.length,
            fullsize_image_url: data.data.entries[i].fullsize_image_url,
            entryIndex: i + (page - 1) * count,
          }
        if count > data.data.entries.length + 1
          $('#load-more').hide()

        page++

        if window.entryData.entries is "undefined"
          window.entryData.entries = []

        window.entryData.entries = window.entryData.entries.concat data.data.entries
        window.entryData.metadata = data.metadata
        window.util.showImageDetail()

      error : () ->
        window.console.log "error"
    }
  load_contents(window.stamp_ids, window.child_ids)
  $('#load-more').on 'click', () ->
    load_contents(window.stamp_ids, window.child_ids)
  $('#image_upload').on 'click', () ->
    location.href = '/image/web/upload'
  $('#group_by_stamp').on 'click', (e) ->
    window.showGroupByModal(e)

  tmpl_stamp = _.template $('#template-stamp').html()
  tmpl_child = _.template $('#template-child').html()
  window.showGroupByModal = (e) ->
    e.stopPropagation()
    $("#groupByStampModal").modal {
      "backdrop": true
    }
    $.ajax {
      "url" : "/profile/get.json"
      "type": "get"
      "processData": true
      "contentType": false
      success: (response) ->
        $("#modal_group_by_child").html ''
        for i in [0 .. response.child.length - 1]
          HTML = tmpl_child
            name: response.child[i].child_name
            id: response.child[i].child_id

          $("#modal_group_by_child").append HTML
          $("#" + response.child[i].child_id).on 'click', () ->
            if $(this).attr('class') == "child-name-color-gray"
              $(this).attr 'class', 'child-name-color'
              child_ids_hash[$(this).attr('id')] = 1
            else
              $(this).attr 'class', 'child-name-color-gray'
              child_ids_hash[$(this).attr('id')] = 0
    }

    $.ajax {
      "url" : "/stamp/list.json"
      "type": "get"
      "processData": true
      "contentType": false
      success: (response) ->
        stamp_ids_hash = {}
        child_ids_hash = {}
        $("#modal_group_by_stamp").html ''
        for i in [0 .. response.data.length - 1]
          HTML = tmpl_stamp
            id: response.data[i].stamp_id
            url: response.data[i].icon_url
          $("#modal_group_by_stamp").append HTML
          $("#" + response.data[i].stamp_id).on 'click', () ->
            if $(this).attr('class') == "listed-stamp"
              $(this).attr 'class', 'listed-stamp gray-image'
              stamp_ids_hash[$(this).attr('id')] = 0
            else
              $(this).attr 'class', 'listed-stamp'
              stamp_ids_hash[$(this).attr('id')] = 1
    }

  $("#groupByStampModalSubmit").on 'click', () ->
    $("#groupByStampModal").modal('hide')
    $(".column.size-1of2").empty()
    window.entryData.entries = []
    page = 1
    window.stamp_ids = []
    for key of stamp_ids_hash
      if stamp_ids_hash[key] == 1
        window.stamp_ids.push key
    window.child_ids = []
    for key of child_ids_hash
      if child_ids_hash[key] == 1
        window.child_ids.push key
    load_contents(window.stamp_ids, window.child_ids)

  # ユーザーカスタムアルバム表示
  $("#custom_album").on 'click', () ->

    # もろもろ初期化
    $(".column.size-1of2").empty()
    $('#album-items').empty()
    $('#load-more').hide()
    window.entryData.entries = []
    page = 1

    # アルバム編集画面のためのprofile取得
    $.ajax {
      "url" : "/profile/get.json"
      "type": "get"
      "processData": true
      "contentType": false
      success: (data) ->
        window.profile = data
      error: (data) ->
        window.console.log "error"
    }

    # アルバム情報取得
    $.ajax {
      url : '/album/search.json',
      dataType: "json",
      traditional: true,
      success : (data) ->
        for i in [0 .. data.album_attribute.length - 1]
          window.album_attr[data.album_attribute[i].album_id] = data.album_attribute[i]

          # アルバム表示
          HTML = tmpl_album {
            name : data.album_attribute[i].name
            album_id : data.album_attribute[i].album_id
          }
          $('#album-items').append HTML
          $('#album_id_' + data.album_attribute[i].album_id).on 'click', () ->
            window.stamp_ids = []
            window.child_ids = window.album_attr[$(this).attr("album_id")].child_ids
            load_contents(window.stamp_ids, window.child_ids)
            $('#load-more').show()
            $('#album-items').empty()

          # アルバム編集画面
          HTML = tmpl_album_edit {
            name: data.album_attribute[i].name
            id: data.album_attribute[i].album_id
          }
          $('#album_setting_id_' + data.album_attribute[i].album_id).append(HTML)

          # attributeに連番つける
          attribute_id = 0
          # 子供のattribute
          if data.album_attribute[i].child_data.length > 0
            for j in [0 .. data.album_attribute[i].child_data.length - 1]
              HTML = tmpl_album_element {
                id: data.album_attribute[i].album_id
                attr_id: attribute_id
                key: "写真の子供"
                value: data.album_attribute[i].child_data[j].child_name
              }
              $('#album-edit-element_' + data.album_attribute[i].album_id).append(HTML)
              # アルバムattribute削除
              $('#album_attr_delete_' + data.album_attribute[i].album_id + '_' + attribute_id).on 'click', () ->
                delete_attr('child_id', $(this).attr('album_attr_delete_id'), $(this).attr('album_attr_delete_value'))
              attribute_id += 1
          # 共有先relativeのattritute
          if data.album_attribute[i].relative_data.length > 0
            for j in [0 .. data.album_attribute[i].relative_data.length - 1]
              HTML = tmpl_album_element {
                id: data.album_attribute[i].album_id
                key: "シェア先"
                attr_id: attribute_id
                value: data.album_attribute[i].relative_data[j].relative_name
              }
              $('#album-edit-element_' + data.album_attribute[i].album_id).append(HTML)
              # アルバムattribute削除
              $('#album_attr_delete_' + data.album_attribute[i].album_id + '_' + attribute_id).on 'click', () ->
                delete_attr('relative_id', $(this).attr('album_attr_delete_id'), $(this).attr('album_attr_delete_value'))
              attribute_id += 1
          $('#new_album_key_' + data.album_attribute[i].album_id).append('<option value="1">写真のこども</option>')
          $('#new_album_key_' + data.album_attribute[i].album_id).append('<option value="2">シェア先</option>')
          $('#new_album_key_' + data.album_attribute[i].album_id).on 'change', () ->
            $('#new_album_attr_' + $(this).attr('album_key_id')).empty()
            window.album_key_id = ''
            if $(this).val() == "1"
              window.album_key_id = 'child_id'
              for i in [0 .. window.profile.child.length - 1]
                j = i + 1
                $('#new_album_attr_' + $(this).attr('album_key_id')).append '<option value="' + window.profile.child[i].child_id + '">' + window.profile.child[i].child_name + '</option>'
            else if $(this).val() == "2"
              window.album_key_id = 'relative_id'
              for i in [0 .. window.profile.relatives.length - 1]
                j = i + 1
                $('#new_album_attr_' + $(this).attr('album_key_id')).append '<option value="' + window.profile.relatives[i].relative_id  + '">' + window.profile.relatives[i].relative_name + '</option>'
          # attribute追加
          $('#add_album_attr_' + data.album_attribute[i].album_id).on 'click', () ->
            token = getXSRFToken()
            $.ajax {
              url : '/album/add_attr',
              dataType: "json",
              type: "post",
              data: {
                "XSRF-TOKEN": token,
                album_id: $(this).attr('add_album_attr_id'),
                key: window.album_key_id,
                attr: $('#new_album_attr_' + $(this).attr('add_album_attr_id')).val(),
              },
              success : (data) ->
                window.console.log data
              error : (e) ->
                window.console.log e
            }

          # 編集ボタンを押すと編集画面出てくる
          $('#album_edit_id_' + data.album_attribute[i].album_id).on 'click', () ->
            $('#album_setting_id_' + $(this).attr('album_edit_id')).show()
            $('#album_edit_id_' + $(this).attr('album_edit_id')).hide()

          # アルバム名編集
          $('#album_name_edit_' + data.album_attribute[i].album_id).on 'click', () ->
            token = getXSRFToken()
            $.ajax {
              url : '/album/edit_name',
              dataType: "json",
              type: "post",
              data: {
                "XSRF-TOKEN": token,
                album_id: $(this).attr('album_name_edit_id'),
                album_name: $('#album_name_edit_form_' + $(this).attr('album_name_edit_id')).val(),
              },
              success : (data) ->
                window.console.log "success"
              error : () ->
                window.console.log "error"
            }
      error : () ->
        window.console.log "error"
    }
  delete_attr = (type, id, attr) ->
    token = getXSRFToken()
    $.ajax {
      url : '/album/delete_attr',
      dataType: "json",
      type: "post",
      data: {
        "XSRF-TOKEN": token,
        album_id: id,
        attr_key: type,
        attr_value: attr,
      },
      success : (data) ->
        window.console.log data
      error : (e) ->
        window.console.log e
    }
