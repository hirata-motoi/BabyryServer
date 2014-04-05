(function() {
  var admitRelativeApply, cancelRelativeApply, console, createAdmittedText, createAdmittingIcon, createApplyingText, createCancelIcon, createIcon, createRejectIcon, createRelativesApplyIcon, createUserName, createloadingIcon, getXSRFToken, refleshRelativesList, rejectRelativeApply, requestRelativeOperate, searchUser, sendRelativeApply, trimIcon;

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
    $.mobile.loading("show", {});
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
        $.mobile.loading("hide");
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
          searchResult.append(createIcon(user.icon_url));
          searchResult.append(createUserName(user.user_name));
          if (user.relative_relation === "approved" || user.relative_relation === "admitting" || user.relative_relation === "applying") {
            continue;
          } else {
            applyIcon = createRelativesApplyIcon();
          }
          searchResult.append(applyIcon);
          $("#search-result-container").append(searchResult);
          _results.push($("#search-result-container").listview("refresh"));
        }
        return _results;
      },
      "error": function() {
        return $.mobile.loading("hide");
      }
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
        container = item.parents(".list-view-item-container");
        clonedItem = item.clone();
        item.remove();
        clonedItem.find("button").remove();
        $("#approved").find("ul").prepend(clonedItem);
        $("#approved").show();
        if (container.find(".list-view-item").length < 1) {
          container.hide();
        }
        return $("#approved-list").listview("refresh");
      },
      "error": function() {}
    });
  };

  createRelativesApplyIcon = function() {
    var applyIcon, applyIconDiv;
    applyIconDiv = $("<div>");
    applyIconDiv.addClass("apply-icon-div");
    applyIcon = $("<button>");
    applyIcon.addClass("relatives-operation-icon");
    applyIcon.text("申請");
    applyIcon.on("click", sendRelativeApply);
    applyIconDiv.append(applyIcon);
    return applyIconDiv;
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
        var e, elem, elems, email, list, r, relation, relative_id, _i, _len, _ref, _results;
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
            elem.append(createIcon(data.relatives[relation][relative_id].icon_url));
            elem.append(createUserName(data.relatives[relation][relative_id].user_name));
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
          _ref = elems[r];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            e = _ref[_i];
            $("#" + r + "-list").append(e);
            $("#" + r + "-list").listview("refresh");
          }
          _results.push($("#" + r).find("a").trigger("click"));
        }
        return _results;
      },
      "error": function() {}
    });
  };

  createIcon = function(icon_url) {
    var img, imgDiv;
    imgDiv = $("<div>");
    imgDiv.addClass("icon-image-parent-div");
    img = $("<img>");
    img.attr("src", icon_url);
    img.addClass("icon-image");
    img.on("load", trimIcon);
    imgDiv.append(img);
    return imgDiv;
  };

  createUserName = function(user_name) {
    var userName, userNameDiv;
    userNameDiv = $("<div>");
    userNameDiv.addClass("user-name-div");
    userName = $("<span>");
    userName.addClass("user-name-elem");
    userName.text(user_name);
    userNameDiv.append(userName);
    return userNameDiv;
  };

  trimIcon = function() {
    var ih, img, imgDisplaySize, iw, nh, nw, rh, rw;
    imgDisplaySize = 80;
    img = $(this)[0];
    nw = img.naturalWidth;
    nh = img.naturalHeight;
    if (nw > nh) {
      rh = imgDisplaySize;
      rw = imgDisplaySize * nw / nh;
    } else {
      rw = imgDisplaySize;
      rh = imgDisplaySize * nh / nw;
    }
    iw = (rw - imgDisplaySize) / 2;
    ih = (rh - imgDisplaySize) / 2;
    $(img).css("top", "-" + ih + "px");
    $(img).css("left", "-" + iw + "px");
    $(img).css("width", rw + "px");
    return $(img).css("height", rh + "px");
  };

  $('a[data-toggle="tab"]').on("shown.bs.tab", function() {
    $("#search-form").val("");
    return $("#search-result-container").empty();
  });

  $("#search-submit").on("click", searchUser);

  refleshRelativesList();

}).call(this);

//# sourceMappingURL=../../static/js/relatives.js.map
