(function() {
  var child_ids_hash, console, count;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  if (window.entryData === "undefined") {
    window.entryData = {};
  }

  window.pageForEntrySearch = 1;

  count = 10;

  window.showGroupByModal;

  window.child_ids = [];

  child_ids_hash = [];

  window.setupWall = function() {
    var load_contents;
    load_contents = function(child_ids) {
      var grid, tmpl;
      tmpl = _.template($('#template-item').html());
      grid = $('.timeline').get(0);
      return $.ajax({
        url: '/entry/search.json',
        dataType: "json",
        traditional: true,
        data: {
          child_id: child_ids,
          count: count,
          page: window.pageForEntrySearch
        },
        success: function(data) {
          var i, item, _i, _j, _ref, _ref1;
          if (data.data.entries.length < 1) {
            return;
          }
          item = [];
          for (i = _i = 0, _ref = data.data.entries.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            item.push(document.createElement('article'));
          }
          salvattore.append_elements(grid, item);
          for (i = _j = 0, _ref1 = data.data.entries.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
            item[i].outerHTML = tmpl({
              comment_num: data.data.entries[i].comments.length,
              fullsize_image_url: data.data.entries[i].fullsize_image_url,
              entryIndex: i + (window.pageForEntrySearch - 1) * count
            });
          }
          if (count > data.data.entries.length + 1) {
            $('#load-more').hide();
          }
          window.pageForEntrySearch++;
          if (window.entryData.entries === "undefined") {
            window.entryData.entries = [];
          }
          window.entryData.entries = window.entryData.entries.concat(data.data.entries);
          window.entryData.metadata = data.metadata;
          window.entryData.related_child = data.data.related_child;
          return window.util.showImageDetail();
        },
        error: function() {
          return window.console.log("error");
        }
      });
    };
    load_contents(window.child_ids);
    $('#load-more').on('click', function() {
      return load_contents(window.child_ids);
    });
    $('#image_upload').on('click', function() {
      return location.href = '/image/web/upload';
    });
    return window.load_contents = load_contents;
  };

}).call(this);

//# sourceMappingURL=../../static/js/wall.js.map
