# model

# TODO: Comment, Stamp

class ModelBase extends Backbone.Model

class Entry extends ModelBase
  idAttribute: 'image_id'
  
window.Babyry.Model = {}
window.Babyry.Model.Base  = ModelBase
window.Babyry.Model.Entry = Entry
