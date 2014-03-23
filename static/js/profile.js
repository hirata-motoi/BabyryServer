// Generated by CoffeeScript 1.6.3
(function() {
  var console;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {
    var grid_child, grid_user, tmpl_child, tmpl_user;
    tmpl_user = _.template($('#template-user-profile').html());
    tmpl_child = _.template($('#template-child-profile').html());
    grid_user = $('.user-timeline').get(0);
    grid_child = $('.child-timeline').get(0);
    return $.ajax({
      url: '/profile/get.json',
      success: function(data) {
        var child_item, i, user_item, _i, _j, _ref, _ref1, _results;
        user_item = [];
        user_item.push(document.createElement('article'));
        salvattore.append_elements(grid_user, user_item);
        user_item[0].outerHTML = tmpl_user({
          url: data.icon_image_url,
          name: data.user_name
        });
        if (data.child.length !== 0) {
          child_item = [];
          for (i = _i = 0, _ref = data.child.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            child_item.push(document.createElement('article'));
          }
          salvattore.append_elements(grid_child, child_item);
          _results = [];
          for (i = _j = 0, _ref1 = data.child.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
            _results.push(child_item[i].outerHTML = tmpl_child({
              name: data.child[i].child_name
            }));
          }
          return _results;
        }
      },
      error: function() {
        return window.console.log("error");
      }
    });
  });

}).call(this);