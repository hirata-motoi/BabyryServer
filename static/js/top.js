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
      $('#top_activate').hide();
      $('#top_password_forget').hide();
      return $('#top_password_change').hide();
    });
    $('.register').on('click', function() {
      $('#top_choice').hide();
      $('#top_login').hide();
      $('#top_register').show();
      $('#top_activate').hide();
      $('#top_password_forget').hide();
      return $('#top_password_change').hide();
    });
    $('.logout').on('click', function() {
      return location.href = '/logout';
    });
    return $('#password_forget').on('click', function() {
      $('#top_choice').hide();
      $('#top_login').hide();
      $('#top_register').hide();
      $('#top_activate').hide();
      $('#top_password_forget').show();
      return $('#top_password_change').hide();
    });
  });

}).call(this);

//# sourceMappingURL=../../static/js/top.js.map
