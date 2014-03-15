(function() {
  var console, getXSRFToken, setXSRFTokenToForm;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

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
    token = getXSRFToken;
    return $("form").each(function(i, form) {
      var $input, method;
      method = $(form).attr("method");
      if (method === "get" || method === "GET") {
        return;
      }
      $input = $("<input>");
      $input.attr("type", "hidden");
      $input.attr("name", "XSRF-TOKEN");
      $input.attr("value", token);
      return $(form).append($input);
    });
  };

  setXSRFTokenToForm();

}).call(this);

//# sourceMappingURL=../../static/js/main.js.map
