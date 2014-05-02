if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->
$ ->

# custom_albumボタンをclickした時の動作
# アルバムリストを出したいが、今はchildのリスト出すだけでOK
showAlbumList = () ->
  # child listを取得
  childList = window.entryData.related_child
  if !childList || childList.length < 1
    # TODO 表示するものがないよ  と表示
    return

  # listviewで表示
  content = $( $("#template-album-list-content").html() )
  content.find("ul").addClass "child-list"

  tmpl_list = _.template $("#template-album-list").html()
  for child in childList
    elem = tmpl_list
      icon_url   : child.icon_url
      child_name : child.child_name
      child_id   : child.child_id
    content.find(".child-list").append $(elem)

  $(".dynamic-container").html content
  $(".child-list").listview()
  $(".child-elem").on "click", showAlbumDetail
    

# showAlbumListで表示されたlistviewの一つをclickした時の動作
# そのアルバムに含まれる写真の一覧
# 今は単にchild指定でsearchすればOK
showAlbumDetail = () ->
  # タップされたchildのchild_idを取得
  childId = $(this).attr "data-child-id"

  # wallのload_contentsを呼ぶ
  content = _.template $("#template-album-content").html()
  $(".dynamic-container").html content({})

  # jsonp
  script = $("<script>")
  script.attr "src", "/static/salvattore/js/salvattore.min.js"
  $(".dynamic-container").append script

  window.pageForEntrySearch = 1
  window.load_contents [], [childId]

  # headerに戻るを追加
  back = $("#header-back-button")
  back.text "back"

  # 戻るのclickイベントにshowAlbumListを登録
  back.attr "href", "#"
  back.on "click", () ->
    showAlbumList()
    return false
  

$("#album-view").on "click", showAlbumList
