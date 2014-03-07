(function() {
  var CollectionBase, Entries, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  CollectionBase = (function(_super) {
    __extends(CollectionBase, _super);

    function CollectionBase() {
      _ref = CollectionBase.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return CollectionBase;

  })(Backbone.Collection);

  Entries = (function(_super) {
    __extends(Entries, _super);

    function Entries() {
      _ref1 = Entries.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Entries.prototype.model = Babyry.Model.Entry;

    return Entries;

  })(CollectionBase);

  window.Babyry.Collection = {};

  window.Babyry.Collection.Base = CollectionBase;

  window.Babyry.Collection.Entries = Entries;

}).call(this);

//# sourceMappingURL=../../static/js/collection.js.map
