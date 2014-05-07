(function() {
  var cancelSelecteImage, console, getXSRFToken, openAttachChildToImages, pickedSharedRelatives, pickedTargetChild, redirectToWall, setXSRFTokenToForm, setupImageUpload, showErrorMessage, showLoadingImage, submit, toggleCheckMark;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

  showLoadingImage = function() {
    var box, cancelIcon, image, innerBox;
    box = $("<div>").addClass("js-uploaded-image-box");
    innerBox = $("<div>").addClass("js-uploaded-image-box-inner");
    innerBox.addClass("inner-box");
    image = $("<img>");
    image.attr("src", "/static/img/ajax-loader.gif");
    image.addClass("image-elem");
    image.css("width", "30");
    image.css("height", "30");
    innerBox.append(image);
    cancelIcon = $("<img>").attr("src", "/static/img/cancel-selected-image.png");
    cancelIcon.addClass("cancel-icon");
    cancelIcon.css({
      "width": "20px",
      "height": "20px"
    });
    innerBox.append(cancelIcon);
    cancelIcon.hide();
    cancelIcon.on("click", cancelSelecteImage);
    box.append(innerBox);
    $(".js-image-container").append(box);
    return box;
  };

  submit = function() {
    var filenames, relatives, targetChild, token;
    filenames = [];
    $(".js-uploaded-image-box").each(function() {
      return filenames.push($(this).attr("filename"));
    });
    token = getXSRFToken();
    relatives = pickedSharedRelatives();
    targetChild = pickedTargetChild();
    return $.ajax("/image/web/submit.json", {
      type: "post",
      data: {
        "shared_user_ids": relatives,
        "target_child_ids": targetChild,
        "image_tmp_names": filenames,
        "XSRF-TOKEN": token
      },
      dataType: 'json',
      success: redirectToWall,
      error: function(xhr) {
        return showErrorMessage(xhr);
      }
    });
  };

  redirectToWall = function(data) {
    return location.href = "/";
  };

  showErrorMessage = function(xhr) {
    return $(".error").show();
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
    var elem, relativeIds;
    return relativeIds = (function() {
      var _i, _len, _ref, _results;
      _ref = $(".relative-checked-mark.checked");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        elem = _ref[_i];
        _results.push($(elem).parent(".relative-list").attr("data-relative-id"));
      }
      return _results;
    })();
  };

  pickedTargetChild = function() {
    var childIds, elem;
    return childIds = (function() {
      var _i, _len, _ref, _results;
      _ref = $(".child-checked-mark.checked");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        elem = _ref[_i];
        _results.push($(elem).parent(".child-list").attr("data-child-id"));
      }
      return _results;
    })();
  };

  toggleCheckMark = function() {
    var checkedMark;
    checkedMark = $(this).find(".checked-mark");
    if ($(checkedMark).hasClass("checked")) {
      return $(checkedMark).removeClass("checked");
    } else {
      return $(checkedMark).addClass("checked");
    }
  };

  openAttachChildToImages = function() {
    window.attachedChildToImages = [];
    return $("#childModal").modal();
  };

  setXSRFTokenToForm = function() {
    var token;
    token = getXSRFToken;
    return $("form").each(function(i, form) {
      var $input, method;
      method = $(form).attr("method");
      if (method === "get" || method === "GET") {
        return;
      }
      $input = $("<input>");
      $input.attr("type", "hidden");
      $input.attr("name", "XSRF-TOKEN");
      $input.attr("value", token);
      return $(form).append($input);
    });
  };

  setupImageUpload = function() {
    var $form;
    $form = $("#image-post-form");
    $form.find("[type=file]").on("change", function() {
      var box, fd;
      $(".error").hide();
      box = showLoadingImage();
      fd = new FormData($form[0]);
      $.ajax($form.attr("action"), {
        type: 'post',
        processData: false,
        contentType: false,
        data: fd,
        dataType: 'json',
        success: function(data) {
          box.find(".image-elem").attr("src", "");
          box.attr("filename", data.image_tmp_name);
          box.find(".image-elem").attr("src", data.image_tmp_url);
          box.find(".image-elem").css("width", "80");
          box.find(".image-elem").css("height", "80");
          return box.find(".cancel-icon").show();
        },
        error: function(xhr) {
          box.remove();
          return showErrorMessage(xhr);
        }
      });
      return false;
    });
    setXSRFTokenToForm();
    $("#image-upload-submit-button").on("click", submit);
    $(".relative-list,.child-list").on("click", toggleCheckMark);
    $("#image-upload-child-mapping").on("click", openAttachChildToImages);
    return $("#add-image-icon").on("click", function() {
      $("#image-post-form").find("[type=file]").trigger("click");
      return false;
    });
  };

  cancelSelecteImage = function() {
    return $(this).parents(".js-uploaded-image-box").remove();
  };

  $(document).off("pagechange");

  $(document).on("pagechange", setupImageUpload);

}).call(this);

//# sourceMappingURL=../../../static/js/image/upload.js.map
