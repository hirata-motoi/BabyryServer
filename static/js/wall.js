(function() {
  var child_ids_hash, console, count, stamp_ids_hash;

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

  window.stamp_ids = [];

  window.child_ids = [];

  stamp_ids_hash = [];

  child_ids_hash = [];

  window.setupWall = function() {
    var load_contents, tmpl_child, tmpl_stamp;
    $("#group_by_stamp").show();
    load_contents = function(stamp_ids, child_ids) {
      var grid, tmpl;
      tmpl = _.template($('#template-item').html());
      grid = $('.timeline').get(0);
      return $.ajax({
        url: '/entry/search.json',
        dataType: "json",
        traditional: true,
        data: {
          stamp_id: stamp_ids,
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
          window.console.log(grid);
          window.console.log(item);
          salvattore.append_elements(grid, item);
          window.console.log("append_elements OK");
          for (i = _j = 0, _ref1 = data.data.entries.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
            item[i].outerHTML = tmpl({
              stamp_num: data.data.entries[i].stamps.length,
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
    load_contents(window.stamp_ids, window.child_ids);
    $('#load-more').on('click', function() {
      return load_contents(window.stamp_ids, window.child_ids);
    });
    $('#image_upload').on('click', function() {
      return location.href = '/image/web/upload';
    });
    $('#group_by_stamp').on('click', function(e) {
      return window.showGroupByModal(e);
    });
    tmpl_stamp = _.template($('#template-stamp').html());
    tmpl_child = _.template($('#template-child').html());
    window.showGroupByModal = function(e) {
      e.stopPropagation();
      $("#groupByStampModal").modal({
        "backdrop": true
      });
      $.ajax({
        "url": "/profile/get.json",
        "type": "get",
        "processData": true,
        "contentType": false,
        success: function(response) {
          var HTML, i, _i, _ref, _results;
          $("#modal_group_by_child").html('');
          _results = [];
          for (i = _i = 0, _ref = response.child.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            HTML = tmpl_child({
              name: response.child[i].child_name,
              id: response.child[i].child_id
            });
            $("#modal_group_by_child").append(HTML);
            _results.push($("#" + response.child[i].child_id).on('click', function() {
              if ($(this).attr('class') === "child-name-color-gray") {
                $(this).attr('class', 'child-name-color');
                return child_ids_hash[$(this).attr('id')] = 1;
              } else {
                $(this).attr('class', 'child-name-color-gray');
                return child_ids_hash[$(this).attr('id')] = 0;
              }
            }));
          }
          return _results;
        }
      });
      return $.ajax({
        "url": "/stamp/list.json",
        "type": "get",
        "processData": true,
        "contentType": false,
        success: function(response) {
          var HTML, i, _i, _ref, _results;
          stamp_ids_hash = {};
          child_ids_hash = {};
          $("#modal_group_by_stamp").html('');
          _results = [];
          for (i = _i = 0, _ref = response.data.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            HTML = tmpl_stamp({
              id: response.data[i].stamp_id,
              url: response.data[i].icon_url
            });
            $("#modal_group_by_stamp").append(HTML);
            _results.push($("#" + response.data[i].stamp_id).on('click', function() {
              if ($(this).attr('class') === "listed-stamp") {
                $(this).attr('class', 'listed-stamp gray-image');
                return stamp_ids_hash[$(this).attr('id')] = 0;
              } else {
                $(this).attr('class', 'listed-stamp');
                return stamp_ids_hash[$(this).attr('id')] = 1;
              }
            }));
          }
          return _results;
        }
      });
    };
    $("#groupByStampModalSubmit").on('click', function() {
      var key, page;
      $("#groupByStampModal").modal('hide');
      $(".column.size-1of2").empty();
      window.entryData.entries = [];
      page = 1;
      window.stamp_ids = [];
      for (key in stamp_ids_hash) {
        if (stamp_ids_hash[key] === 1) {
          window.stamp_ids.push(key);
        }
      }
      window.child_ids = [];
      for (key in child_ids_hash) {
        if (child_ids_hash[key] === 1) {
          window.child_ids.push(key);
        }
      }
      return load_contents(window.stamp_ids, window.child_ids);
    });
    return window.load_contents = load_contents;
  };

}).call(this);

//# sourceMappingURL=../../static/js/wall.js.map
