(function() {
  var admitRelativeApply, cancelRelativeApply, console, createAdmittedText, createAdmittingIcon, createApplyingText, createCancelIcon, createRejectIcon, createRelativesApplyIcon, createloadingIcon, getXSRFToken, refleshRelativesList, rejectRelativeApply, requestRelativeOperate, searchUser, sendRelativeApply;

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

  searchUser = function() {
    var searchString;
    searchString = $("#search-form").val();
    $("#search-result-container").empty();
    return $.ajax({
      "url": "/relatives/search.json",
      "type": "get",
      "processData": true,
      "data": {
        "str": searchString
      },
      "dataType": "json",
      "success": function(data) {
        var applyIcon, index, searchResult, user, _i, _len, _ref, _results;
        if (!data.users) {
          return;
        }
        _ref = data.users;
        _results = [];
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          user = _ref[index];
          searchResult = $("<li>");
          searchResult.attr("user-id", user.user_id);
          searchResult.addClass("list-view-item");
          if (user.relative_relation === "approved" || user.relative_relation === "admitting" || user.relative_relation === "applying") {
            continue;
          } else {
            applyIcon = createRelativesApplyIcon();
          }
          searchResult.text(user.user_name);
          searchResult.append(applyIcon);
          _results.push($("#search-result-container").append(searchResult));
        }
        return _results;
      },
      "error": function() {}
    });
  };

  createAdmittingIcon = function() {
    var icon;
    icon = $("<button>");
    icon.addClass("relatives-operation-icon");
    icon.text("承認する");
    icon.on("click", admitRelativeApply);
    return icon;
  };

  createCancelIcon = function() {
    var icon;
    icon = $("<button>");
    icon.addClass("relatives-operation-icon");
    icon.text("取り消す");
    icon.on("click", cancelRelativeApply);
    return icon;
  };

  createRejectIcon = function() {
    var icon;
    icon = $("<button>");
    icon.addClass("relatives-operation-icon");
    icon.text("拒否");
    icon.on("click", rejectRelativeApply);
    return icon;
  };

  admitRelativeApply = function() {
    var button, item, token, userId;
    button = $(this);
    item = button.parents(".list-view-item");
    userId = item.attr("user-id");
    token = getXSRFToken();
    button.text("");
    button.append(createloadingIcon());
    return $.ajax({
      "url": "/relatives/admit.json",
      "type": "post",
      "data": {
        "user_id": userId,
        "XSRF-TOKEN": token
      },
      "success": function() {
        var clonedItem, container;
        clonedItem = item.clone();
        item.remove();
        clonedItem.find("button").remove();
        $("#approved").find("ul").prepend(clonedItem);
        $("#approved").show();
        container = item.parents(".list-view-item-container");
        if (container.find(".list-view-item").length < 1) {
          return container.hide();
        }
      },
      "error": function() {}
    });
  };

  createRelativesApplyIcon = function() {
    var icon;
    icon = $("<button>");
    icon.addClass("relatives-operation-icon");
    icon.text("申請");
    icon.on("click", sendRelativeApply);
    return icon;
  };

  sendRelativeApply = function() {
    var button, searchResult, token, userId;
    button = $(this);
    searchResult = button.parents(".list-view-item");
    userId = searchResult.attr("user-id");
    token = getXSRFToken();
    button.text("");
    button.append(createloadingIcon());
    return $.ajax({
      "url": "/relatives/apply.json",
      "type": "post",
      "data": {
        "user_id": userId,
        "XSRF-TOKEN": token
      },
      "success": function() {
        var applyingText;
        button.remove();
        applyingText = createApplyingText();
        searchResult.append(applyingText);
        return refleshRelativesList();
      },
      "error": function() {}
    });
  };

  createApplyingText = function() {
    var applyingText;
    applyingText = $("<span>");
    applyingText.addClass("relatives-operation-icon");
    applyingText.text("申請中");
    return applyingText;
  };

  createAdmittedText = function() {
    var applyingText;
    applyingText = $("<span>");
    applyingText.addClass("relatives-operation-icon");
    applyingText.text("承認済み");
    return applyingText;
  };

  createloadingIcon = function() {
    var img;
    img = $("<img>");
    img.attr("src", "/static/img/ajax-loader.gif");
    img.addClass("loading-image");
    return img;
  };

  requestRelativeOperate = function(button, url) {
    var tab, target, token, userId;
    target = button.parent(".list-view-item");
    tab = button.parents(".tab-pane").attr("id");
    userId = target.attr("user-id");
    token = getXSRFToken();
    button.text("");
    button.append(createloadingIcon());
    return $.ajax({
      "url": url,
      "type": "post",
      "data": {
        "user_id": userId,
        "XSRF-TOKEN": token
      },
      "success": function() {
        var container;
        container = target.parents(".list-view-item-container");
        target.remove();
        if (container.find(".list-view-item").length < 1) {
          return container.hide();
        }
      },
      "error": function() {}
    });
  };

  cancelRelativeApply = function() {
    var button, url;
    button = $(this);
    url = "/relatives/cancel.json";
    return requestRelativeOperate(button, url);
  };

  rejectRelativeApply = function() {
    var button, url;
    button = $(this);
    url = "/relatives/reject.json";
    return requestRelativeOperate(button, url);
  };

  refleshRelativesList = function() {
    return $.ajax({
      "url": "/relatives/list.json",
      "type": "get",
      "success": function(data) {
        var e, elem, elems, email, list, r, relation, relative_id, _results;
        if (!data.relatives) {
          return;
        }
        elems = {};
        for (relation in data.relatives) {
          elems[relation] = [];
          for (relative_id in data.relatives[relation]) {
            email = data.relatives[relation][relative_id].email;
            elem = $("<li>");
            elem.attr("user-id", relative_id);
            elem.addClass("list-view-item");
            elem.text(relative_id + " : " + email);
            if (relation === "applying") {
              elem.append(createCancelIcon());
            } else if (relation === "admitting") {
              elem.append(createRejectIcon());
              elem.append(createAdmittingIcon("list"));
            }
            elems[relation].push(elem);
          }
        }
        list = $("#list .list-view");
        list.find("li").hide();
        list.find("ul").empty();
        _results = [];
        for (r in elems) {
          $("#" + r).show();
          _results.push((function() {
            var _i, _len, _ref, _results1;
            _ref = elems[r];
            _results1 = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              e = _ref[_i];
              _results1.push($("#" + r + "-list").append(e));
            }
            return _results1;
          })());
        }
        return _results;
      },
      "error": function() {}
    });
  };

  $('a[data-toggle="tab"]').on("shown.bs.tab", function() {
    $("#search-form").val("");
    return $("#search-result-container").empty();
  });

  $("#search-submit").on("click", searchUser);

  refleshRelativesList();

}).call(this);

//# sourceMappingURL=../../static/js/relatives.js.map
