(function() {
  var console, getXSRFToken, hidePageLoading, setHeaderElem, setXSRFTokenToForm, showFooterEffect, showPageLoading;

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

  showPageLoading = function() {
    return $.mobile.loading("show");
  };

  hidePageLoading = function() {
    return $.mobile.loading("hide");
  };

  showFooterEffect = function() {
    var path, target;
    path = location.pathname;
    $(".navbar .selected-footer-menu").each(function() {
      return $(this).removeClass("selected-footer-menu");
    });
    target = path === "/" ? $("#footer-home") : path === "/image/web/upload" ? $("#footer-upload") : $("#footer-other");
    window.console.log(target);
    target.find("a").css("border-bottom", "solid 3px rgba(255, 230, 62, 1.0)");
    return target.find("img").css("margin-bottom", "-3px");
  };

  setHeaderElem = function() {
    var path;
    path = location.pathname;
    if (path === "/") {
      return $("#album-view").show();
    } else {
      return $("#album-view").hide();
    }
  };

  window.util || (window.util = {});

  window.util.showPageLoading = showPageLoading;

  window.util.hidePageLoading = hidePageLoading;

  $(document).on("pagechange", setXSRFTokenToForm);

  $(document).on("DOMContentLoaded", function() {
    showFooterEffect();
    return setHeaderElem();
  });

}).call(this);

//# sourceMappingURL=../../static/js/main.js.map
