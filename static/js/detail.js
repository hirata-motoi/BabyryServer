(function() {
  var console, owlObject, showImageDetail, _base, _base1;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

  /*
  set event to click each image
  this part will be replaced by methods in entries.coffee
  */


  window.entryData || (window.entryData = {});

  (_base = window.entryData).entries || (_base.entries = []);

  (_base1 = window.entryData).metadata || (_base1.metadata = {});

  window.stampData || (window.stampData = {});

  window.stampsByImagePosition || (window.stampsByImagePosition = {});

  window.stamp_ids || (window.stamp_ids = []);

  window.entryIdsInArray = [];

  window.loadingFlg = false;

  window.displayedElementsFlg = true;

  owlObject = void 0;

  showImageDetail = function() {
    var adjustDisplayedElements, alreadyAttachedStamp, backToWall, closeComments, createCommentNavigation, createImageBox, createStamp, createStampAttachIcon, editStamps, getCurrentEntryId, getData, getNextIds, getStampData, getStampHash, getXSRFToken, hasElem, pickData, preserveResponseData, replaceToolBoxContent, setStampAttachList, setStampsByImagePosition, setUpScreenSize, shouldPreLoad, showComments, showEntries, showErrorMessage, showLoadingImage, showNavBarFooter, toggleDisplayedElements, toggleStamp, upsertStampsByImagePosition;
    $(".img-thumbnail").on("click", function() {
      var $elem, comment_count, data, i, imageId, image_id, image_url, initialIndex, innerHeight, innerWidth, n, owlContainer, stampElem, stampInfo, stampList, stamps, tappedEntryIndex, _i, _j, _len, _ref;
      setUpScreenSize();
      window.util.showPageLoading();
      $(".container").addClass("full-size-screen");
      innerWidth = window.innerWidth;
      innerHeight = window.innerHeight;
      $(".container.content-body").css("width", innerWidth);
      $(".container.content-body").css("height", innerHeight);
      imageId = $(this).parents(".item").attr("image_id");
      data = pickData();
      tappedEntryIndex = $(this).attr("entryIndex");
      upsertStampsByImagePosition(data.list);
      owlContainer = $(".owl-carousel").clone(true);
      owlContainer.addClass("displayed");
      for (i = _i = 0, _ref = data.found_row_count - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (data.list[i]) {
          image_url = data.list[i].fullsize_image_url;
          window.entryIdsInArray.push(data.list[i].image_id);
          stamps = data.list[i].stamps;
          image_id = data.list[i].image_id;
          comment_count = data.list[i].comments.length;
        } else {
          image_url = "";
          image_id = "";
          comment_count = 0;
        }
        $elem = createImageBox(image_url, image_id, comment_count, innerWidth, innerHeight);
        owlContainer.append($elem);
        if (data.list[i] && data.list[i].image_id === imageId) {
          initialIndex = i;
        }
        if (stamps) {
          stampList = [];
          for (n = _j = 0, _len = stamps.length; _j < _len; n = ++_j) {
            stampInfo = stamps[n];
            stampElem = createStamp(stampInfo.stamp_id, stampInfo.icon_url);
            $elem.find(".stamp-container").append(stampElem);
          }
        }
        $elem.find(".stamp-container").hide();
      }
      $("#navbar-space").hide();
      $(".dynamic-container").html(owlContainer);
      $(window).scrollTop(0);
      $(".owl-carousel.displayed").owlCarousel({
        items: 1,
        pagination: false,
        scrollPerPage: true,
        beforeMove: function() {},
        afterMove: function() {
          var count, currentPageNo, loadingFlg;
          replaceToolBoxContent();
          if (shouldPreLoad(5)) {
            if (window.loadingFlg) {
              return;
            }
            currentPageNo = 1;
            count = 10;
            showLoadingImage();
            loadingFlg = true;
            return getData(showEntries, showErrorMessage);
          }
        }
      });
      owlObject = $(".owl-carousel").data("owlCarousel");
      owlObject.jumpTo(tappedEntryIndex);
      window.util.hidePageLoading();
      return showNavBarFooter();
    });
    $("#comment-submit").on("click", function() {
      var comment, currentPosition, imageElem, imageId, token;
      token = getXSRFToken();
      comment = $("#comment-textarea").val();
      currentPosition = owlObject.currentPosition();
      imageElem = $(".img-box")[currentPosition];
      imageId = $(imageElem).attr("image-id");
      return $.ajax({
        "type": "post",
        "url": "/image/comment.json",
        "data": {
          "image_id": imageId,
          "comment": comment,
          "XSRF-TOKEN": token
        },
        "dataType": "json",
        "success": function(data) {
          var commentCount, item, tmpl;
          tmpl = _.template($('#template-comment-item').html());
          item = tmpl({
            commenter_icon_url: data.commented_by_icon_url,
            commenter_name: data.commented_by_name,
            comment_text: data.comment
          });
          $("#all-comment-container").find("ul").append(item);
          window.entryData.entries[currentPosition].comments.push({
            "comment": comment
          });
          $("#comment-textarea").val("");
          commentCount = window.entryData.entries[currentPosition].comments.length;
          return $(imageElem).find(".comment-notice").text(createCommentNavigation(commentCount));
        }
      });
    });
    shouldPreLoad = function(num) {
      if (window.entryIdsInArray.length < owlObject.currentPosition() + num) {
        return true;
      } else {
        return false;
      }
    };
    preserveResponseData = function(response) {
      var entry, _i, _len, _ref;
      _ref = response.data.entries;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        entry = _ref[_i];
        window.entryData.entries.push(entry);
      }
      return window.entryData.metadata = response.metadata;
    };
    pickData = function() {
      return {
        list: window.entryData.entries,
        found_row_count: window.entryData.metadata.found_row_count
      };
    };
    getData = function(successCallback, errorCallback) {
      var countPerPage, nextPage;
      nextPage = window.entryData.metadata.page ? parseInt(window.entryData.metadata.page, 10) + 1 : 1;
      countPerPage = window.entryData.metadata.count || 10;
      return $.ajax({
        "url": "/entry/search.json",
        "processData": true,
        "contentType": false,
        "data": {
          stamp_id: window.stamp_ids,
          "page": nextPage,
          "count": countPerPage
        },
        "dataType": 'json',
        "success": successCallback,
        "error": errorCallback
      });
    };
    createImageBox = function(image_url, image_id, comment_count, innerWidth, innerHeight) {
      var owlElem, tmpl;
      tmpl = $("#item-tmpl").clone(true);
      owlElem = $(tmpl);
      owlElem.find(".img-box").attr("image-id", image_id);
      owlElem.find(".img-box").css("background-image", "url(" + image_url + ")");
      owlElem.css("width", innerWidth);
      owlElem.css("height", innerHeight);
      owlElem.attr("id", "");
      if (!image_url) {
        owlElem.addClass("unloaded");
      }
      owlElem.find(".img-box").on("click", toggleDisplayedElements);
      owlElem.find(".comment-notice").on("click", function() {
        var comment, comments, currentPosition, item, _i, _len;
        $(".comment-container").empty();
        currentPosition = owlObject.currentPosition();
        comments = window.entryData.entries[currentPosition].comments;
        comments.sort(function(a, b) {
          var aCreatedAt, bCreatedAt;
          aCreatedAt = a.created_at;
          bCreatedAt = b.created_at;
          if (aCreatedAt < bCreatedAt) {
            return -1;
          }
          if (aCreatedAt > bCreatedAt) {
            return 1;
          }
          return 0;
        });
        tmpl = _.template($('#template-comment-item').html());
        if (comments) {
          for (_i = 0, _len = comments.length; _i < _len; _i++) {
            comment = comments[_i];
            item = tmpl({
              commenter_icon_url: comment.commented_by_icon_url,
              commenter_name: comment.commented_by_name,
              comment_text: comment.comment
            });
            $(".comment-container").prepend(item);
          }
        }
        return $("#commentModal").modal("show");
      });
      owlElem.show();
      return owlElem;
    };
    showLoadingImage = function() {
      return $(".unloadedElems").first().find(".img-box img").attr("src", "/static/img/ajax-loader.gif");
    };
    showErrorMessage = function() {};
    showEntries = function(response) {
      var elem, i, image_url, unloadedElems, _i, _len;
      if (response.data.entries.length < 1) {
        return;
      }
      preserveResponseData(response);
      unloadedElems = $(".unloaded");
      for (i = _i = 0, _len = unloadedElems.length; _i < _len; i = ++_i) {
        elem = unloadedElems[i];
        if (response.data.entries[i]) {
          image_url = response.data.entries[i].fullsize_image_url;
          $(elem).find(".img-box").css("background-image", "url('" + image_url + "')");
          $(elem).find(".loading").removeClass("loading");
          $(elem).removeClass("unloaded");
          window.entryIdsInArray.push(response.data.entries[i].image_id);
        } else {
          window.loadingFlg = false;
          break;
        }
      }
      return window.loadingFlg = false;
    };
    getNextIds = function() {
      var currentEntryId;
      return currentEntryId = getCurrentEntryId;
    };
    getCurrentEntryId = function() {};
    alreadyAttachedStamp = function(stampId, currentPosition) {
      var _base2;
      (_base2 = window.stampsByImagePosition)[currentPosition] || (_base2[currentPosition] = {});
      if (window.stampsByImagePosition[currentPosition][stampId] === true) {
        return true;
      } else {
        return false;
      }
    };
    setStampsByImagePosition = function(stampId, currentPosition, value) {
      var _base2;
      (_base2 = window.stampsByImagePosition)[currentPosition] || (_base2[currentPosition] = {});
      return window.stampsByImagePosition[currentPosition][stampId] = value;
    };
    upsertStampsByImagePosition = function(entries) {
      var entry, i, n, stamp, _base2, _i, _len, _results;
      _results = [];
      for (i = _i = 0, _len = entries.length; _i < _len; i = ++_i) {
        entry = entries[i];
        (_base2 = window.stampsByImagePosition)[i] || (_base2[i] = {});
        _results.push((function() {
          var _j, _len1, _ref, _results1;
          _ref = entry.stamps;
          _results1 = [];
          for (n = _j = 0, _len1 = _ref.length; _j < _len1; n = ++_j) {
            stamp = _ref[n];
            _results1.push(window.stampsByImagePosition[i][stamp.stamp_id] = true);
          }
          return _results1;
        })());
      }
      return _results;
    };
    toggleStamp = function() {
      var aa, currentPosition, imageId, stampElem, stampHash, stampIconUrl, stampId, target, targetImgBox, targetStamp, token;
      stampId = $(this).attr("stamp-id");
      currentPosition = owlObject.currentPosition();
      stampHash = getStampHash();
      stampIconUrl = stampHash[stampId].icon_url;
      targetImgBox = $(".img-box")[currentPosition];
      imageId = $(targetImgBox).attr("image-id");
      target = $("#attached-stamps-container");
      if (alreadyAttachedStamp(stampId, currentPosition)) {
        targetStamp = target.find('img[stamp-id="' + stampId + '"]').parent();
        targetStamp.hide();
        token = getXSRFToken();
        return $.ajax({
          "url": "/stamp/detach.json",
          "type": "post",
          "data": {
            "image_id": imageId,
            "stamp_id": stampId,
            "XSRF-TOKEN": token
          },
          "dataType": "json",
          "success": function(response) {
            var stampContainer;
            targetStamp.remove();
            window.console.log($(targetImgBox).find('img[stamp-id="' + stampId + '"]').parent());
            stampContainer = $(targetImgBox).find('img[stamp-id="' + stampId + '"]').parent();
            stampContainer.remove();
            return window.stampsByImagePosition[currentPosition][stampId] = false;
          },
          "error": function(xhr, textStatus, errorThrown) {
            return targetStamp.show();
          }
        });
      } else {
        stampElem = createStamp(stampId, stampIconUrl);
        aa = $("#attached-stamps-container").find("ul").append(stampElem);
        $(targetImgBox).find(".stamp-container").append(stampElem.clone(true));
        setStampsByImagePosition(stampId, currentPosition, true);
        token = getXSRFToken();
        return $.ajax({
          "url": "/stamp/attach.json",
          "type": "post",
          "data": {
            "image_id": imageId,
            "stamp_id": stampId,
            "XSRF-TOKEN": token
          },
          "dataType": "json",
          "error": function(xhr, textStatus, errorThrown) {
            var regexp, res;
            res = $.parseJSON(xhr.responseText);
            regexp = new RegExp("stamp", "i");
            if (res.error_messages.stamp_id && res.error_messages.stamp_id[0].match(regexp)) {

            } else {
              return window.stampsByImagePosition[currentPosition][stampId] = false;
            }
          }
        });
      }
    };
    createStamp = function(stampId, stampIconUrl) {
      var stampElem, stampImage;
      stampElem = $("<li>");
      stampElem.addClass("stamp");
      stampImage = $("<img>");
      stampImage.addClass("stamp-icon");
      stampImage.attr("src", stampIconUrl);
      stampImage.attr("stamp-id", stampId);
      stampElem.append(stampImage);
      return stampElem;
    };
    getStampHash = function() {
      var stamp, stampHash, _i, _len, _ref;
      stampHash = {};
      _ref = window.stampData;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        stamp = _ref[_i];
        stampHash[stamp.stamp_id] = stamp;
      }
      return stampHash;
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
    createStampAttachIcon = function(stamp) {
      var elem, img;
      elem = $("<a>");
      elem.addClass("stamp-attach-icon");
      elem.attr("stamp-id", stamp.stamp_id);
      img = $("<img>");
      img.attr("src", stamp.icon_url);
      img.addClass("listed-stamp");
      elem.append(img);
      elem.on("click", toggleStamp);
      return elem;
    };
    hasElem = function(data) {
      var i, _i, _len;
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        i = data[_i];
        return true;
      }
      return false;
    };
    getStampData = function() {
      return window.stampData;
    };
    setStampAttachList = function() {
      var elem, i, stamp, stampList, _i, _len, _results;
      stampList = getStampData();
      _results = [];
      for (i = _i = 0, _len = stampList.length; _i < _len; i = ++_i) {
        stamp = stampList[i];
        elem = createStampAttachIcon(stamp);
        _results.push($("#stamp-edit-container").append(elem));
      }
      return _results;
    };
    backToWall = function() {
      $(".container").removeClass("full-size-screen");
      return location.href = "/";
    };
    toggleDisplayedElements = function() {
      $(".navbar").toggle();
      return window.displayedElementsFlg = $(".navbar").css("display") === "none" ? false : true;
    };
    adjustDisplayedElements = function() {
      var currentPosition, elems, i, imageElem, indexes, _i, _j, _len, _ref, _results, _results1;
      currentPosition = parseInt(owlObject.currentPosition(), 10);
      elems = $(".img-box");
      if (window.entryData.entries.length < 4) {
        indexes = (function() {
          _results = [];
          for (var _i = 0, _ref = window.entryData.entries.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this);
      } else if (currentPosition === 0) {
        indexes = [0, 1];
      } else if (currentPosition === window.entryData.entries.length - 1) {
        indexes = [currentPosition + 0 - 1, currentPosition];
      } else {
        indexes = [currentPosition, currentPosition - 1, currentPosition + 0 + 1];
      }
      _results1 = [];
      for (_j = 0, _len = indexes.length; _j < _len; _j++) {
        i = indexes[_j];
        imageElem = $(elems[i]);
        if (window.displayedElementsFlg) {
          imageElem.find(".stamp-container").show();
          _results1.push(imageElem.find(".img-footer").show());
        } else {
          imageElem.find(".stamp-container").hide();
          _results1.push(imageElem.find(".img-footer").hide());
        }
      }
      return _results1;
    };
    replaceToolBoxContent = function() {
      var commentCountText, commentItem, comments, currentPosition, elems, stampContainer;
      currentPosition = parseInt(owlObject.currentPosition(), 10);
      elems = $(".img-box");
      stampContainer = $($(elems)[currentPosition]).find(".stamp-container").clone(true);
      $("#attached-stamps-container").find("ul").html(stampContainer.html());
      $("#recent-comment-container").empty();
      comments = window.entryData.entries[currentPosition].comments;
      comments.sort(function(a, b) {
        var aCreatedAt, bCreatedAt;
        aCreatedAt = a.created_at;
        bCreatedAt = b.created_at;
        if (aCreatedAt < bCreatedAt) {
          return -1;
        }
        if (aCreatedAt > bCreatedAt) {
          return 1;
        }
        return 0;
      });
      commentItem = $("<span>");
      commentItem.text(comments[0].comment);
      $("#recent-comment-container").append(commentItem);
      commentCountText = createCommentNavigation(window.entryData.entries[currentPosition].comments.length);
      return $("#comment-count").text(commentCountText);
    };
    createCommentNavigation = function(comment_count) {
      return "コメント" + comment_count + "件";
    };
    showNavBarFooter = function() {
      $("#comment-count").on("click", showComments);
      $("#comment-box").on("click", showComments);
      $("#modal-header").on("click", closeComments);
      $("#stamp-edit").on("click", editStamps);
      return $(".navbar-footer").show();
    };
    showComments = function() {
      var comment, comments, container, currentPosition, item, list, tmpl;
      container = $("#all-comment-container");
      currentPosition = parseInt(owlObject.currentPosition(), 10);
      comments = window.entryData.entries[currentPosition].comments;
      comments.sort(function(a, b) {
        var aCreatedAt, bCreatedAt;
        aCreatedAt = a.created_at;
        bCreatedAt = b.created_at;
        if (aCreatedAt < bCreatedAt) {
          return -1;
        }
        if (aCreatedAt > bCreatedAt) {
          return 1;
        }
        return 0;
      });
      if (comments) {
        tmpl = _.template($('#template-comment-item').html());
        list = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = comments.length; _i < _len; _i++) {
            comment = comments[_i];
            _results.push(item = tmpl({
              commenter_icon_url: comment.commented_by_icon_url,
              commenter_name: comment.commented_by_name,
              comment_text: comment.comment
            }));
          }
          return _results;
        })();
      }
      container.find("ul").empty();
      container.find("ul").append(list);
      $(".navbar-footer").addClass("all-comment-container-opened");
      $("#attached-stamps-container").hide();
      $("#stamp-edit-container").hide();
      $("#recent-comment-container").hide();
      $("#comment-operation-container").hide();
      $("#comment-input-container").show();
      $("#modal-header").show();
      return container.show();
    };
    closeComments = function() {
      $(".navbar-footer").removeClass("all-comment-container-opened");
      $("#attached-stamps-container").show();
      $("#stamp-edit-container").hide();
      $("#recent-comment-container").show();
      $("#comment-operation-container").show();
      $("#comment-input-container").hide();
      $("#all-comment-container").hide();
      return $("#modal-header").hide();
    };
    editStamps = function() {
      $(".navbar-footer").addClass("all-comment-container-opened");
      $("#stamp-edit-container").show();
      $("#recent-comment-container").hide();
      $("#comment-operation-container").hide();
      $("#comment-input-container").hide();
      return $("#modal-header").show();
    };
    setUpScreenSize = function() {
      var rule, screenHeight, ss;
      screenHeight = window.innerHeight - 44;
      rule = ".all-comment-container-opened { height: " + screenHeight + 'px; }';
      ss = document.styleSheets;
      return $(ss).each(function() {
        var idx;
        window.console.log($(this)[0].title);
        if ($(this)[0].title === "dynamic") {
          idx = $(this)[0].cssRules.length;
          return $(this)[0].insertRule(rule, idx);
        }
      });
    };
    if (!hasElem(window.stampData)) {
      return $.ajax({
        "url": "/stamp/list.json",
        "type": "get",
        "processData": true,
        "contentType": false,
        success: function(response) {
          window.stampData = response.data;
          return setStampAttachList();
        }
      });
    } else {
      return setStampAttachList();
    }
  };

  window.util || (window.util = {});

  window.util.showImageDetail = showImageDetail;

}).call(this);

//# sourceMappingURL=../../static/js/detail.js.map
