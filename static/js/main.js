(function() {
  var console, getXSRFToken, setXSRFTokenToForm, showRelatives;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

  showRelatives = function() {
    var key, relative_email, relative_id, relatives, relatives_list;
    relatives = $.parseJSON($(".relatives-data").attr("data-json"));
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

  getXSRFToken = function() {
    var c, cookies, matched, token, _i, _len;
    window.console.log(document.cookie);
    cookies = document.cookie.split(/\s*;\s*/);
    for (_i = 0, _len = cookies.length; _i < _len; _i++) {
      c = cookies[_i];
      matched = c.match(/^XSRF-TOKEN=(.*)$/);
      if (matched != null) {
        token = matched[1];
      }
    }
    return token;
  };

  setXSRFTokenToForm = function() {
    var token;
    window.console.log("bbb");
    token = getXSRFToken;
    return $("form").each(function(i, form) {
      var $input, method;
      method = $(form).attr("method");
      window.console.log("aaa");
      if (method === "get" || method === "GET") {
        return;
      }
      $input = $("<input>");
      $input.attr("type", "hidden");
      $input.attr("name", "XSRF-TOKEN");
      $input.attr("value", token);
      window.console.log($(form));
      return $(form).append($input);
    });
  };

  $("#show-relatives").on('click', showRelatives);

  setXSRFTokenToForm();

}).call(this);

//# sourceMappingURL=../../static/js/main.js.map
