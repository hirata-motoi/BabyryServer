(function() {
  var Entry, ModelBase, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ModelBase = (function(_super) {
    __extends(ModelBase, _super);

    function ModelBase() {
      _ref = ModelBase.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return ModelBase;

  })(Backbone.Model);

  Entry = (function(_super) {
    __extends(Entry, _super);

    function Entry() {
      _ref1 = Entry.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Entry.prototype.idAttribute = 'image_id';

    return Entry;

  })(ModelBase);

  window.Babyry.Model = {};

  window.Babyry.Model.Base = ModelBase;

  window.Babyry.Model.Entry = Entry;

}).call(this);

//# sourceMappingURL=../../static/js/model.js.map
