(function() {
  var console, showAlbumDetail, showAlbumList;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

  showAlbumList = function() {
    var child, childList, content, elem, tmpl_list, _i, _len;
    childList = window.entryData.related_child;
    if (!childList || childList.length < 1) {
      return;
    }
    content = $($("#template-album-list-content").html());
    content.find("ul").addClass("child-list");
    tmpl_list = _.template($("#template-album-list").html());
    for (_i = 0, _len = childList.length; _i < _len; _i++) {
      child = childList[_i];
      elem = tmpl_list({
        icon_url: child.icon_url,
        child_name: child.child_name,
        child_id: child.child_id
      });
      content.find(".child-list").append($(elem));
    }
    $(".dynamic-container").html(content);
    $(".child-list").listview();
    return $(".child-elem").on("click", showAlbumDetail);
  };

  showAlbumDetail = function() {
    var back, childId, content, script;
    childId = $(this).attr("data-child-id");
    content = _.template($("#template-album-content").html());
    $(".dynamic-container").html(content({}));
    script = $("<script>");
    script.attr("src", "/static/salvattore/js/salvattore.min.js");
    $(".dynamic-container").append(script);
    window.pageForEntrySearch = 1;
    window.load_contents([], [childId]);
    back = $("#header-back-button");
    back.text("back");
    back.attr("href", "#");
    return back.on("click", function() {
      showAlbumList();
      return false;
    });
  };

  $("#album-view").on("click", showAlbumList);

}).call(this);

//# sourceMappingURL=../../static/js/album.js.map
