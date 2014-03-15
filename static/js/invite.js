(function() {
  var console, getXSRFToken, inviteSubmit;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

  getXSRFToken = function() {
    var c, cookies, matched, token, _i, _len;
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

  inviteSubmit = function() {
    var token;
    token = getXSRFToken();
    return $.ajax({
      "url": "/invite/execute",
      "type": "post",
      "data": {
        "XSRF-TOKEN": token,
        "aaaa": "bbbbbbbb"
      },
      "dataType": "json",
      "success": function(data) {
        var mailto, query;
        query = "?subject=" + data.subject + "&body=" + data.body;
        mailto = "mailto:" + query;
        return location.href = mailto;
      },
      "error": function() {}
    });
  };

  $("#invite-submit").on("click", inviteSubmit);

}).call(this);

//# sourceMappingURL=../../static/js/invite.js.map
