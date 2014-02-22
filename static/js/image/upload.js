(function() {
  var $form, console, getXSRFToken, pickedSharedRelatives, redirectToWall, showErrorMessage, showTmpImage, submit;

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
    var fd;
    window.console.log("file changed");
    fd = new FormData($form[0]);
    $.ajax($form.attr("action"), {
      type: 'post',
      processData: false,
      contentType: false,
      data: fd,
      dataType: 'json',
      success: showTmpImage,
      error: showErrorMessage
    });
    return false;
  });

  showTmpImage = function(data) {
    var box, image;
    window.console.log(data);
    box = $("<span>").addClass("js-uploaded-image-box");
    box.attr("filename", data.image_tmp_name);
    image = $("<img>");
    image.attr("src", data.image_tmp_url);
    image.css("width", "80");
    image.css("height", "80");
    box.append(image);
    return $(".js-image-container").append(box);
  };

  submit = function() {
    var filenames, relatives, token;
    filenames = [];
    $(".js-uploaded-image-box").each(function() {
      return filenames.push($(this).attr("filename"));
    });
    token = getXSRFToken();
    relatives = pickedSharedRelatives();
    return $.ajax("/image/web/submit.json", {
      type: "post",
      data: {
        "shared_user_ids": relatives,
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

  $("#submit-button").on("click", submit);

}).call(this);

//# sourceMappingURL=../../../static/js/image/upload.js.map
