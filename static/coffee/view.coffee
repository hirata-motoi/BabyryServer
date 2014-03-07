# view

class ViewBase extends Backbone.View
  template = null

  initTemplate: ->
    if not template
      template = _.template $("##{@templateId}").html()
    if not @template
      @template = template
    
  
class Entry extends ViewBase
  className: 'entry'
  templateId: 'entry-view'

  initialize: (config) ->
    @initTemplate()
    @model = config.model

  render: ->
    @$el.html(@template(@model.toJSON))
    @

class Entries extends ViewBase
  id: "app" # -> id="app"のDOMに結びつく

  initialize: (entries) ->
    @entries = entries
    @$el = $("##{@id}")

  render: ->
    @entries.each(_.bind((entry) ->
      @$el.append(new Entry(model: entry).render().$el)
    ,@))
    @$el.html(html)
    @


class FullScreen extends ViewBase

window.Babyry.View = {}
window.Babyry.View.Base       = ViewBase
window.Babyry.View.Entries    = Entries
window.Babyry.View.FullScreen = FullScreen
