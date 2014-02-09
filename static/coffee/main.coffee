if typeof (window.console) is "undefined"
  console = {}
  console.log = console.warn = console.error = (a) ->
$ ->

showRelatives = () -> 
  relatives = $.parseJSON( $(".relatives-data").attr("data-json")  )
  
  window.console.log( relatives );

  relatives_list = for key of relatives
    window.console.log( relatives[key] )
    relative_id    = key 
    relative_email = relatives[key].email || ""
    "id:" + relative_id + " email:" + relative_email
 
  window.confirm( relatives_list.join("\n") )

$("#show-relatives").on('click', showRelatives)

