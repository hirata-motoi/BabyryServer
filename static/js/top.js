(function() {
  var console;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {
    $('.login').on('click', function() {
      $('#top_choice').hide();
      $('#top_login').show();
      $('#top_register').hide();
      return window.console.log(location.href);
    });
    return $('.register').on('click', function() {
      $('#top_choice').hide();
      $('#top_login').hide();
      return $('#top_register').show();
    });
  });

}).call(this);

//# sourceMappingURL=../../static/js/top.js.map
