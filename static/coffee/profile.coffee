if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->

$ ->
  tmpl_user = _.template $('#template-user-profile').html()
  tmpl_child = _.template $('#template-child-profile').html()
  grid_user = $('.user-timeline').get 0
  grid_child = $('.child-timeline').get 0

  $.ajax {
    url : '/profile/get.json',
    success : (data) ->
      user_item = []
      user_item.push document.createElement('article')

      salvattore.append_elements grid_user, user_item
      user_item[0].outerHTML = tmpl_user {
        url: data.icon_image_url,
        name: data.user_name,
      }

      if data.child.length != 0
        child_item = []
        for i in [0 .. data.child.length - 1]
          child_item.push document.createElement('article')

        salvattore.append_elements grid_child, child_item
        for i in [0 .. data.child.length - 1]
          child_item[i].outerHTML = tmpl_child {
            name: data.child[i].child_name
          }
     error: () ->
       window.console.log "error"
   }
