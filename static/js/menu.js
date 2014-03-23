(function() {
  var console;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {
    var grid, i, menu_images, menu_item, menu_title, menu_uri, tmpl, _i, _j, _ref, _ref1, _results;
    tmpl = _.template($('#template-menu').html());
    grid = $('.timeline').get(0);
    menu_images = ["/static/img/menu/profile.png", "/static/img/menu/relatives.png", "/static/img/menu/howto.png", "/static/img/menu/form.png"];
    menu_title = ["プロフィール", "ともだち", "つかいかた", "お問い合わせ"];
    menu_uri = ["/profile", "/relatives", "/", "/"];
    menu_item = [];
    for (i = _i = 0, _ref = menu_images.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      menu_item.push(document.createElement('article'));
    }
    salvattore.append_elements(grid, menu_item);
    _results = [];
    for (i = _j = 0, _ref1 = menu_item.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
      _results.push(menu_item[i].outerHTML = tmpl({
        menu_icon_image: menu_images[i],
        entryIndex: i,
        menu_title: menu_title[i],
        menu_uri: menu_uri[i]
      }));
    }
    return _results;
  });

}).call(this);

//# sourceMappingURL=../../static/js/menu.js.map
