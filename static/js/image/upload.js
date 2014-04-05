(function() {
  var $form, console, getXSRFToken, pickedSharedRelatives, pickedTargetChild, redirectToWall, showErrorMessage, showLoadingImage, submit;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

  $("#add-image-icon").on("click", function() {
    $("#image-post-form").find("[type=file]").trigger("click");
    return false;
  });

  $form = $("#image-post-form");

  $form.find("[type=file]").on("change", function() {
    var box, fd;
    window.console.log("file changed");
    box = showLoadingImage();
    fd = new FormData($form[0]);
    $.ajax($form.attr("action"), {
      type: 'post',
      processData: false,
      contentType: false,
      data: fd,
      dataType: 'json',
      success: function(data) {
        box.find("img").attr("src", "");
        box.attr("filename", data.image_tmp_name);
        box.find("img").attr("src", data.image_tmp_url);
        box.find("img").css("width", "80");
        return box.find("img").css("height", "80");
      },
      error: showErrorMessage
    });
    return false;
  });

  showLoadingImage = function() {
    var box, image, innerBox;
    box = $("<div>").addClass("js-uploaded-image-box");
    box.css("display", "table-cell");
    box.css("width", "100");
    box.css("height", "100");
    box.css("text-align", "center");
    box.css("vertical-align", "middle");
    box.css("padding-left", "6px");
    box.css("padding-right", "6px");
    innerBox = $("<div>");
    innerBox.css("display", "table-cell");
    innerBox.css("width", "88");
    innerBox.css("height", "88");
    innerBox.css("text-align", "center");
    innerBox.css("vertical-align", "middle");
    innerBox.css("border", "solid 1px gray");
    innerBox.css("padding", "1px");
    innerBox.css("margin", "2px");
    innerBox.addClass("inner-box");
    image = $("<img>");
    image.attr("src", "/static/img/ajax-loader.gif");
    image.css("width", "30");
    image.css("height", "30");
    innerBox.append(image);
    box.append(innerBox);
    $(".js-image-container").append(box);
    return box;
  };

  submit = function() {
    var filenames, relatives, target_child, token;
    filenames = [];
    $(".js-uploaded-image-box").each(function() {
      return filenames.push($(this).attr("filename"));
    });
    token = getXSRFToken();
    relatives = pickedSharedRelatives();
    target_child = pickedTargetChild();
    return $.ajax("/image/web/submit.json", {
      type: "post",
      data: {
        "shared_user_ids": relatives,
        "target_child_ids": target_child,
        "image_tmp_names": filenames,
        "XSRF-TOKEN": token
      },
      dataType: 'json',
      success: redirectToWall,
      error: showErrorMessage
    });
  };

  redirectToWall = function(data) {
    return location.href = "/";
  };

  showErrorMessage = function(xhr, textStatus, errorThrown) {
    window.console.log(xhr.responseText);
    return window.alert(xhr.responseText);
  };

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

  pickedSharedRelatives = function() {
    var elem, _i, _len, _ref, _results;
    _ref = $(".js-shared-relatives");
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      elem = _ref[_i];
      if ($(elem).prop("checked") !== true) {
        continue;
      }
      _results.push($(elem).val());
    }
    return _results;
  };

  pickedTargetChild = function() {
    var elem, _i, _len, _ref, _results;
    _ref = $(".js-target-child");
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      elem = _ref[_i];
      if ($(elem).prop("checked") !== true) {
        continue;
      }
      _results.push($(elem).val());
    }
    return _results;
  };

  $("#submit-button").on("click", submit);

}).call(this);

//# sourceMappingURL=../../../static/js/image/upload.js.map
