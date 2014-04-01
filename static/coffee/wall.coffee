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
stamp_ids_hash = []
child_ids_hash = []

$ ->
  tmpl = _.template $('#template-item').html()
  grid = $('.timeline').get 0

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
