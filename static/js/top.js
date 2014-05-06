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
      return $('#top_activate').hide();
    });
    $('.register').on('click', function() {
      $('#top_choice').hide();
      $('#top_login').hide();
      $('#top_register').show();
      return $('#top_activate').hide();
    });
    return $('.logout').on('click', function() {
      return location.href = '/logout';
    });
  });

}).call(this);

//# sourceMappingURL=../../static/js/top.js.map
