(function() {
  var admitRelativeApply, console, createAdmittedText, createAdmittingIcon, createApplyingText, createRelativesApplyIcon, createloadingIcon, getXSRFToken, refleshRelativesList, searchUser, sendRelativeApply;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

  getXSRFToken = function() {
    var c, cookies, matched, token, _i, _len;
    window.console.log(document.cookie);
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
    var searchString, token;
    searchString = $("#search-form").val();
    $("#search-result-container").empty();
    token = getXSRFToken();
    return $.ajax({
      "url": "/relatives/search.json",
      "type": "post",
      "data": {
        "str": searchString,
        "XSRF-TOKEN": token
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
          searchResult.addClass("search-result");
          window.console.log(user.relative_status);
          if (user.relative_relation === 'approved') {
            continue;
          } else if (user.relative_relation === 'applying') {
            applyIcon = createApplyingText();
          } else if (user.relative_relation === 'admitting') {
            applyIcon = createAdmittingIcon();
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
    icon.addClass("relatives-apply-icon");
    icon.text("承認する");
    icon.on("click", admitRelativeApply);
    return icon;
  };

  admitRelativeApply = function() {
    var button, searchResult, token, userId;
    button = $(this);
    searchResult = button.parents(".search-result");
    userId = searchResult.attr("user-id");
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
        var admittedText;
        button.remove();
        admittedText = createAdmittedText();
        searchResult.append(admittedText);
        return refleshRelativesList();
      },
      "error": function() {}
    });
  };

  createRelativesApplyIcon = function() {
    var icon;
    icon = $("<button>");
    icon.addClass("relatives-apply-icon");
    icon.text("申請");
    icon.on("click", sendRelativeApply);
    return icon;
  };

  sendRelativeApply = function() {
    var button, searchResult, token, userId;
    button = $(this);
    searchResult = button.parents(".search-result");
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
    applyingText.addClass("relatives-apply-icon");
    applyingText.text("申請中");
    return applyingText;
  };

  createAdmittedText = function() {
    var applyingText;
    applyingText = $("<span>");
    applyingText.addClass("relatives-apply-icon");
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

  refleshRelativesList = function() {
    return $.ajax({
      "url": "/relatives/list.json",
      "type": "get",
      "success": function(data) {
        var e, elem, elems, email, list, relative_id, _i, _len, _results;
        if (!data.relatives) {
          return;
        }
        elems = [];
        for (relative_id in data.relatives) {
          email = data.relatives[relative_id].email;
          elem = $("<li>");
          elem.text(relative_id + " : " + email);
          elems.push(elem);
        }
        list = $("#list .list-view");
        list.empty();
        _results = [];
        for (_i = 0, _len = elems.length; _i < _len; _i++) {
          e = elems[_i];
          _results.push(list.append(e));
        }
        return _results;
      },
      "error": function() {}
    });
  };

  $("#search-submit").on("click", searchUser);

  refleshRelativesList();

}).call(this);

//# sourceMappingURL=../../static/js/relatives.js.map
