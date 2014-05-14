if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->

if window.entryData is "undefined"
  window.entryData = {}

window.pageForEntrySearch = 1
count = 10

window.showGroupByModal
window.child_ids = []
child_ids_hash = []

window.setupWall = () ->

  load_contents = (child_ids) ->

    tmpl = _.template $('#template-item').html()
    grid = $('.timeline').get 0

    $.ajax {
      url : '/entry/search.json',
      dataType: "json",
      traditional: true,
      data: {
        child_id: child_ids,
        count: count,
        page: window.pageForEntrySearch
      },
      success : (data) ->
        return if data.data.entries.length < 1
        item = []
        for i in [0 .. data.data.entries.length - 1]
          item.push document.createElement('article')

        salvattore.append_elements grid, item
        for i in [0 .. data.data.entries.length - 1]
          item[i].outerHTML = tmpl {
            comment_num: data.data.entries[i].comments.length,
            fullsize_image_url: data.data.entries[i].fullsize_image_url,
            entryIndex: i + (window.pageForEntrySearch - 1) * count,
          }
        if count > data.data.entries.length + 1
          $('#load-more').hide()

        window.pageForEntrySearch++

        if window.entryData.entries is "undefined"
          window.entryData.entries = []

        window.entryData.entries = window.entryData.entries.concat data.data.entries
        window.entryData.metadata = data.metadata
        window.entryData.related_child = data.data.related_child
        window.util.showImageDetail()

      error : () ->
        window.console.log "error"
    }
  load_contents(window.child_ids)
  $('#load-more').on 'click', () ->
    load_contents(window.child_ids)
  $('#image_upload').on 'click', () ->
    location.href = '/image/web/upload'

  window.load_contents = load_contents
