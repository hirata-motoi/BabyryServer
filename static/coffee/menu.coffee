if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->

$ ->
  tmpl = _.template $('#template-menu').html()
  grid = $('.timeline').get 0

  menu_images = [
    "/static/img/menu/profile.png",
    "/static/img/menu/relatives.png",
    "/static/img/menu/howto.png",
    "/static/img/menu/form.png"
  ]
  menu_title = [
    "プロフィール",
    "ともだち",
    "つかいかた",
    "お問い合わせ"
  ]
  menu_uri = [
    "/profile",
    "/relatives",
    "/",
    "/"
  ]

  menu_item = []
  for i in [0 .. menu_images.length - 1]
    menu_item.push document.createElement('article')
  salvattore.append_elements grid, menu_item

  for i in [0 .. menu_item.length - 1]
    menu_item[i].outerHTML = tmpl {
      menu_icon_image: menu_images[i],
      entryIndex: i,
      menu_title: menu_title[i]
      menu_uri: menu_uri[i]
    }
