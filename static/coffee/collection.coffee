# collection

# TODO: Comments, Stamps

class CollectionBase extends Backbone.Collection

class Entries extends CollectionBase
  model: Babyry.Model.Entry
  
window.Babyry.Collection = {}
window.Babyry.Collection.Base    = CollectionBase
window.Babyry.Collection.Entries = Entries
