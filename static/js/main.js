(function() {
  var console, showRelatives;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

  showRelatives = function() {
    var key, relative_email, relative_id, relatives, relatives_list;
    relatives = $.parseJSON($(".relatives-data").attr("data-json"));
    window.console.log(relatives);
    relatives_list = (function() {
      var _results;
      _results = [];
      for (key in relatives) {
        window.console.log(relatives[key]);
        relative_id = key;
        relative_email = relatives[key].email || "";
        _results.push("id:" + relative_id + " email:" + relative_email);
      }
      return _results;
    })();
    return window.confirm(relatives_list.join("\n"));
  };

  $("#show-relatives").on('click', showRelatives);

}).call(this);

//# sourceMappingURL=../../static/js/main.js.map
