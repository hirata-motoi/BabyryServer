(function() {
  var Entries, Entry, FullScreen, ViewBase, _ref, _ref1, _ref2, _ref3,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ViewBase = (function(_super) {
    var template;

    __extends(ViewBase, _super);

    function ViewBase() {
      _ref = ViewBase.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    template = null;

    ViewBase.prototype.initTemplate = function() {
      if (!template) {
        template = _.template($("#" + this.templateId).html());
      }
      if (!this.template) {
        return this.template = template;
      }
    };

    return ViewBase;

  })(Backbone.View);

  Entry = (function(_super) {
    __extends(Entry, _super);

    function Entry() {
      _ref1 = Entry.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Entry.prototype.className = 'entry';

    Entry.prototype.templateId = 'entry-view';

    Entry.prototype.initialize = function(config) {
      this.initTemplate();
      return this.model = config.model;
    };

    Entry.prototype.render = function() {
      this.$el.html(this.template(this.model.toJSON));
      return this;
    };

    return Entry;

  })(ViewBase);

  Entries = (function(_super) {
    __extends(Entries, _super);

    function Entries() {
      _ref2 = Entries.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Entries.prototype.id = "app";

    Entries.prototype.initialize = function(entries) {
      this.entries = entries;
      return this.$el = $("#" + this.id);
    };

    Entries.prototype.render = function() {
      this.entries.each(_.bind(function(entry) {
        return this.$el.append(new Entry({
          model: entry
        }).render().$el);
      }, this));
      this.$el.html(html);
      return this;
    };

    return Entries;

  })(ViewBase);

  FullScreen = (function(_super) {
    __extends(FullScreen, _super);

    function FullScreen() {
      _ref3 = FullScreen.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    return FullScreen;

  })(ViewBase);

  window.Babyry.View = {};

  window.Babyry.View.Base = ViewBase;

  window.Babyry.View.Entries = Entries;

  window.Babyry.View.FullScreen = FullScreen;

}).call(this);

//# sourceMappingURL=../../static/js/view.js.map
