if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->

if window.entryData is "undefined"
  window.entryData = {}

page = 1
count = 10

$ ->
  tmpl = _.template $('#template-item').html()
  grid = $('.timeline').get 0

  load_contents = () ->
    $.ajax {
      url : '/entry/search.json',
      dataType: "json",
      data: {
        count: count,
        page: page
      },
      success : (data) ->
        item = []
        for i in [0 .. data.data.entries.length]
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

  load_contents()

  $('#load-more').on 'click', load_contents
  $('#image_upload').on 'click', () ->
    location.href = '/image/web/upload'

