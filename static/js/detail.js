(function() {
  var console, defaultTextareaHeight, innerHeight, innerWidth, navbarFooterHIdeLocked, navbarShow, owlObject, showImageDetail, _base, _base1, _base2;

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

  (_base2 = window.entryData).related_child || (_base2.related_child = {});

  window.child_ids || (window.child_ids = []);

  owlObject = void 0;

  defaultTextareaHeight = "30px";

  innerWidth = 0;

  innerHeight = 0;

  navbarShow = true;

  navbarFooterHIdeLocked = false;

  showImageDetail = function() {
    var addChildToEntryData, adjustHeightOfChildEditContainer, alreadyAttachedChild, attachChildToImage, closeComments, confirmRemoveImage, createChild, createCommentNavigation, createImageBox, createOwlElementsWithResponse, detachChildFromImage, editChild, getCurrentEntryIndex, getCurrentPosition, getData, getXSRFToken, hasElem, hideAttachedChild, initEditChild, initializeDisplayedElements, pickData, preserveResponseData, refreshChildAttachedMark, removeAttachedChild, removeImage, replaceToolBoxContent, setChildAttachList, setUpScreenSize, setupGlobalFooter, showAttachedChild, showCarousel, showComments, showEntries, showErrorMessage, showLoadingImage, showNavBarFooter, toggleDisplayedElements;
    $(".img-thumbnail").on("click", function() {
      var imageId, tappedEntryIndex;
      $("#global-header").toolbar({
        tapToggle: true,
        fullscreen: true
      });
      setUpScreenSize();
      setupGlobalFooter();
      window.util.showPageLoading();
      innerWidth = window.innerWidth;
      innerHeight = window.innerHeight;
      imageId = $(this).parents(".item").attr("image_id");
      tappedEntryIndex = $(this).attr("entryIndex");
      toggleDisplayedElements();
      return showCarousel({
        offset: tappedEntryIndex
      }, function() {
        var data;
        window.util.hidePageLoading();
        showNavBarFooter();
        data = pickData();
        setChildAttachList(data.related_child);
        window.console.log($(".owl-carousel.displayed").parents("[data-role=\"page\"]")[0]);
        return $($(".owl-carousel.displayed").parents("[data-role=\"page\"]")[0]).css({
          "cssText": "padding-top: 0px !important; padding-bottom: 0px !important;"
        });
      });
    });
    $("#comment-submit").on("click", function() {
      var comment, imageElem, imageId, token;
      token = getXSRFToken();
      comment = $("#comment-textarea").val();
      imageElem = $(".img-box")[getCurrentPosition()];
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
          window.entryData.entries[getCurrentEntryIndex()].comments.push(data);
          $("#comment-textarea").val("");
          $("#comment-textarea").css("height", defaultTextareaHeight);
          commentCount = window.entryData.entries[getCurrentEntryIndex()].comments.length;
          return $("#comment-count").text(createCommentNavigation(commentCount));
        }
      });
    });
    preserveResponseData = function(response) {
      window.entryData.entries = response.data.entries;
      window.entryData.metadata = response.metadata;
      return window.entryData.related_child = response.data.related_child;
    };
    pickData = function() {
      return {
        list: window.entryData.entries,
        found_row_count: window.entryData.metadata.found_row_count,
        related_child: window.entryData.related_child,
        metadata: window.entryData.metadata
      };
    };
    getData = function(offset, initial, addOnCallback) {
      var countPerPage, nextPage;
      nextPage = window.entryData.metadata.page ? parseInt(window.entryData.metadata.page, 10) + 1 : 1;
      countPerPage = window.entryData.metadata.count || 10;
      $.mobile.loading("show");
      return $.ajax({
        "url": "/entry/search.json",
        "processData": true,
        "contentType": false,
        "data": {
          "page": nextPage,
          "count": countPerPage,
          "offset": offset
        },
        "dataType": 'json',
        "success": function(response) {
          $(".container.content-body").css("width", innerWidth);
          $(".container.content-body").css("height", innerHeight);
          showEntries(response, initial);
          if (typeof addOnCallback === "function") {
            return addOnCallback();
          }
        },
        "error": showErrorMessage,
        "complete": function() {
          return $.mobile.loading("hide");
        }
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
      owlElem.show();
      return owlElem;
    };
    showLoadingImage = function() {
      return $(".unloadedElems").first().find(".img-box img").attr("src", "/static/img/ajax-loader.gif");
    };
    showErrorMessage = function() {};
    showEntries = function(response, initial) {
      var initialIndex, owlContainer, ret;
      if (response.data.entries.length < 1) {
        return;
      }
      preserveResponseData(response);
      ret = createOwlElementsWithResponse(initial);
      owlContainer = ret.owlContainer;
      initialIndex = ret.initialIndex;
      $(".container").addClass("full-size-screen");
      $(".dynamic-container").html(owlContainer);
      $(".owl-carousel.displayed").owlCarousel({
        items: 1,
        pagination: false,
        scrollPerPage: true,
        afterMove: function() {
          return replaceToolBoxContent();
        }
      });
      owlObject = $(".owl-carousel.displayed").data("owlCarousel");
      owlObject.jumpTo(initialIndex);
      return replaceToolBoxContent();
    };
    createOwlElementsWithResponse = function(initial) {
      var buttonAfter, buttonBefore, childElem, childInfo, childList, comment_count, count, data, div, elem, entry, image_id, image_url, initialIndex, length, moreImageAfterElem, moreImageBeforeElem, n, offset, owlContainer, _i, _j, _len, _len1, _ref;
      data = pickData();
      count = parseInt(data.found_row_count, 10);
      offset = parseInt(data.metadata.offset, 10);
      length = data.list.length;
      initialIndex = initial === "max" ? data.list.length - 1 : 0;
      owlContainer = $(".owl-carousel.template").clone(true);
      owlContainer.removeClass("template");
      owlContainer.addClass("displayed");
      if (0 < offset) {
        moreImageBeforeElem = createImageBox("/static/img/stamp/icon/1.jpeg", 0, 0, innerWidth, innerHeight);
        buttonBefore = $("<a href=\"#\" class=\"btn btn-info btn-large\">YES</a>");
        buttonBefore.on("click", function() {
          showCarousel({
            minIndex: offset
          });
          return false;
        });
        div = $("<div style=\"position: relative; margin-top: 100px\">もっとみるかニャ？</div>");
        div.append(buttonBefore);
        moreImageBeforeElem.find(".img-box").append(div);
        moreImageBeforeElem.find(".img-box").addClass("moreImage");
        owlContainer.append(moreImageBeforeElem);
        initialIndex = initialIndex + 1;
      }
      _ref = data.list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        entry = _ref[_i];
        image_url = entry.fullsize_image_url;
        childList = entry.child;
        image_id = entry.image_id;
        comment_count = entry.comments.length;
        elem = createImageBox(image_url, image_id, comment_count, innerWidth, innerHeight);
        owlContainer.append(elem);
        if (childList) {
          for (n = _j = 0, _len1 = childList.length; _j < _len1; n = ++_j) {
            childInfo = childList[n];
            childElem = createChild(childInfo.child_id, childInfo.child_name);
            elem.find(".child-container").append(childElem);
          }
        }
        elem.find(".child-container").hide();
      }
      if (count > offset + length) {
        moreImageAfterElem = createImageBox("/static/img/stamp/icon/1.jpeg", 0, 0, innerWidth, innerHeight);
        buttonAfter = $("<a href=\"#\" class=\"btn btn-info btn-large\">YES</a>");
        buttonAfter.on("click", function() {
          showCarousel({
            maxIndex: offset + length - 1
          });
          return false;
        });
        div = $("<div style=\"position: relative; margin-top: 100px\">もっとみるかニャ？</div>");
        div.append(buttonAfter);
        moreImageAfterElem.find(".img-box").append(div);
        moreImageAfterElem.find(".img-box").addClass("moreImage");
        owlContainer.append(moreImageAfterElem);
      }
      return {
        owlContainer: owlContainer,
        initialIndex: initialIndex
      };
    };
    createChild = function(childId, childName) {
      var childElem, text;
      childElem = $($("#child-tag-tmpl").clone(true).html());
      childElem.attr("data-child-id", childId);
      text = childName.length > 10 ? childName.substr(0, 10) + "..." : childName;
      childElem.find("a").text(text);
      return childElem;
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
    hasElem = function(data) {
      var i, _i, _len;
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        i = data[_i];
        return true;
      }
      return false;
    };
    toggleDisplayedElements = function() {
      if ($("#global-header").hasClass("in")) {
        $("#operation-container").removeClass("slidedown-out");
        return $("#operation-container").addClass("slideup-in");
      } else {
        $("#operation-container").removeClass("slideup-in");
        return $("#operation-container").addClass("slidedown-out");
      }
    };
    initializeDisplayedElements = function() {
      navbarFooterHIdeLocked = false;
      if (navbarShow) {
        return $(".navbar").show();
      } else {
        return $(".navbar").hide();
      }
    };
    replaceToolBoxContent = function() {
      var childContainer, commentCount, commentCountText, commentItem, comments, currentEntryIndex, elems;
      currentEntryIndex = getCurrentEntryIndex();
      elems = $(".img-box");
      if ($($(elems)[getCurrentPosition()]).hasClass("moreImage")) {
        $(".navbar-footer").hide();
        navbarFooterHIdeLocked = true;
        return;
      } else {
        navbarFooterHIdeLocked = false;
      }
      childContainer = $($(elems)[currentEntryIndex]).find(".child-container").clone(true);
      $("#child-tag-container").find("ul").html(childContainer.html());
      $("#recent-comment-container").empty();
      comments = window.entryData.entries[currentEntryIndex].comments;
      if (comments && comments.length > 0) {
        comments.sort(function(a, b) {
          var aCreatedAt, bCreatedAt;
          aCreatedAt = a.created_at;
          bCreatedAt = b.created_at;
          if (aCreatedAt < bCreatedAt) {
            return 1;
          }
          if (aCreatedAt > bCreatedAt) {
            return -1;
          }
          return 0;
        });
        commentItem = $("<p>");
        commentItem.text(comments[0].comment);
        $("#recent-comment-container").append(commentItem);
        commentCount = comments.length;
        $("#recent-comment-container").show();
      } else {
        commentCount = 0;
        $("#recent-comment-container").hide();
      }
      commentCountText = createCommentNavigation(commentCount);
      $("#comment-count").text(commentCountText);
      return initializeDisplayedElements();
    };
    createCommentNavigation = function(comment_count) {
      return "コメント" + comment_count + "件";
    };
    showNavBarFooter = function() {
      $("#comment-count").on("click", showComments);
      $("#comment-edit-icon").on("click", showComments);
      $("#child-edit-icon").on("click", editChild);
      $("#modal-header").on("click", closeComments);
      $("#remove-image-icon").on("click", confirmRemoveImage);
      $("#remove-image-submit").on("click", removeImage);
      return $(".navbar-footer").show();
    };
    showComments = function() {
      var comment, comments, container, item, list, tmpl;
      container = $("#all-comment-container");
      comments = window.entryData.entries[getCurrentEntryIndex()].comments;
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
      if (comments.length > 0) {
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
      $("#attached-child-tag-container").hide();
      $("#child-edit-container").hide();
      $("#recent-comment-container").hide();
      $("#comment-operation-container").hide();
      $("#comment-input-container").show();
      if (!comments.length) {
        $("#comment-input-container").find("textarea").focus();
      }
      $("#modal-header").show();
      return container.show();
    };
    closeComments = function() {
      $(".navbar-footer").removeClass("all-comment-container-opened");
      $("#attached-child-tag-container").show();
      $("#child-edit-container").hide();
      $("#recent-comment-container").show();
      $("#comment-operation-container").show();
      $("#child-message-container").hide();
      $("#comment-input-container").hide();
      $("#all-comment-container").hide();
      return $("#modal-header").hide();
    };
    editChild = function() {
      $(".navbar-footer").addClass("all-comment-container-opened");
      $("#attached-child-tag-container").hide();
      $("#child-edit-container").show();
      initEditChild();
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
        if ($(this)[0].title === "dynamic") {
          idx = $(this)[0].cssRules.length;
          return $(this)[0].insertRule(rule, idx);
        }
      });
    };
    initEditChild = function() {
      var child, childHash, currentEntryIndex, _base3, _i, _len, _ref;
      currentEntryIndex = getCurrentEntryIndex();
      (_base3 = window.entryData.entries[currentEntryIndex]).child || (_base3.child = []);
      childHash = {};
      _ref = window.entryData.entries[currentEntryIndex].child;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        childHash[child.child_id] = true;
      }
      $(".child-attach-item").each(function() {
        var childId;
        childId = $(this).attr("data-child-id");
        if (childHash[childId]) {
          return $(this).find(".child-attached-mark span").show();
        } else {
          return $(this).find(".child-attached-mark span").hide();
        }
      });
      refreshChildAttachedMark();
      $("#child-edit-container").find("ul").listview("refresh");
      if ($(".child-attach-item").length < 1) {
        $("#child-edit-container,#child-tag-container").hide();
        $("#child-message-container").show();
      }
      return adjustHeightOfChildEditContainer();
    };
    adjustHeightOfChildEditContainer = function() {
      var height, modalHeight, navbarHeight, tagContainerHeight;
      navbarHeight = parseInt($("#global-header").css("height").replace(/px/, ""), 10);
      modalHeight = parseInt($("#modal-header").css("height").replace(/px/, ""), 10);
      tagContainerHeight = parseInt($("#child-tag-container").css("height").replace(/px/, ""), 10);
      height = innerHeight - navbarHeight - modalHeight - tagContainerHeight - 20;
      return $("#child-edit-container").css("height", height + "px");
    };
    setupGlobalFooter = function() {
      return $("#global-footer").hide();
    };
    setChildAttachList = function(related_child) {
      var child, child_id, child_name, icon_url, item, itemObj, tmpl, _i, _len, _results;
      if (!related_child || related_child.length < 1) {
        return;
      }
      _results = [];
      for (_i = 0, _len = related_child.length; _i < _len; _i++) {
        child = related_child[_i];
        icon_url = child.icon_url;
        child_id = child.child_id;
        child_name = child.child_name;
        tmpl = _.template($('#template-child-attach-item').html());
        item = tmpl({
          child_icon_url: icon_url,
          child_name: child_name,
          child_id: child_id
        });
        itemObj = $(item);
        _results.push($("#child-edit-container").find("ul").append(itemObj));
      }
      return _results;
    };
    attachChildToImage = function() {
      var childElem, childId, childName, imageElem, imageId, token;
      childId = $(this).attr("data-child-id");
      childName = $(this).find(".child-name").text();
      imageElem = $(".img-box")[getCurrentEntryIndex()];
      imageId = $(imageElem).attr("image-id");
      token = getXSRFToken();
      childElem = createChild(childId, childName);
      if (!alreadyAttachedChild(childId)) {
        $("#child-tag-container").find("ul").append(childElem);
      }
      $(this).find(".child-attached-mark span").show();
      return $.ajax({
        url: "/image/child/attach.json",
        type: "POST",
        data: {
          "image_id": imageId,
          "child_id": childId,
          "XSRF-TOKEN": token
        },
        dataType: "json",
        success: function(response) {
          if (!response.rows || response.rows < 1) {
            removeAttachedChild(childId);
            refreshChildAttachedMark();
            return;
          }
          if (addChildToEntryData(childId, childName)) {
            $(imageElem).find(".child-container").append(childElem.clone(true));
            return refreshChildAttachedMark();
          }
        },
        error: function() {
          removeAttachedChild(childId);
          return refreshChildAttachedMark();
        }
      });
    };
    hideAttachedChild = function(childId) {
      var childTags, tag, _i, _len, _results;
      childTags = $("#child-tag-container").find(".child-tag-li");
      _results = [];
      for (_i = 0, _len = childTags.length; _i < _len; _i++) {
        tag = childTags[_i];
        if (childId === $(tag).attr("data-child-id")) {
          _results.push($(tag).hide());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    showAttachedChild = function(childId) {
      var childTags, tag, _i, _len, _results;
      childTags = $("#child-tag-container").find(".child-tag-li");
      _results = [];
      for (_i = 0, _len = childTags.length; _i < _len; _i++) {
        tag = childTags[_i];
        if (childId === $(tag).attr("data-child-id")) {
          _results.push($(tag).show());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    removeAttachedChild = function(childId) {
      var child, childList, childTags, currentEntryIndex, index, length, tag, _i, _j, _len, _ref, _results;
      childTags = $("#child-tag-container").find(".child-tag-li");
      for (_i = 0, _len = childTags.length; _i < _len; _i++) {
        tag = childTags[_i];
        if (childId === $(tag).attr("data-child-id")) {
          $(tag).remove();
        }
      }
      currentEntryIndex = getCurrentEntryIndex();
      $($(".img-box")[currentEntryIndex]).find(".child-tag-li").each(function() {
        if (childId === $(this).attr("data-child-id")) {
          return $(this).remove();
        }
      });
      childList = window.entryData.entries[currentEntryIndex].child;
      length = childList.length;
      _results = [];
      for (index = _j = _ref = length - 1; _ref <= 0 ? _j <= 0 : _j >= 0; index = _ref <= 0 ? ++_j : --_j) {
        child = childList[index];
        if (child.child_id === childId) {
          _results.push(childList.splice(index, 1));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    alreadyAttachedChild = function(childId) {
      var child, childList, currentEntryIndex, index, _base3, _i, _len;
      currentEntryIndex = getCurrentEntryIndex();
      (_base3 = window.entryData.entries[currentEntryIndex]).child || (_base3.child = []);
      childList = window.entryData.entries[currentEntryIndex].child;
      for (index = _i = 0, _len = childList.length; _i < _len; index = ++_i) {
        child = childList[index];
        if (child.child_id === childId) {
          return true;
        }
      }
    };
    addChildToEntryData = function(childId, childName) {
      var currentEntryIndex, _base3;
      currentEntryIndex = getCurrentEntryIndex();
      (_base3 = window.entryData.entries[currentEntryIndex]).child || (_base3.child = []);
      if (alreadyAttachedChild(childId)) {
        return false;
      }
      window.entryData.entries[currentEntryIndex].child.push({
        "child_id": childId,
        "child_name": childName
      });
      return true;
    };
    detachChildFromImage = function() {
      var childId, childName, imageElem, imageId, token;
      childId = $(this).attr("data-child-id");
      childName = $(this).find(".child-name").text();
      imageElem = $(".img-box")[getCurrentEntryIndex()];
      imageId = $(imageElem).attr("image-id");
      token = getXSRFToken();
      hideAttachedChild(childId);
      $(this).find(".child-attached-mark span").hide();
      return $.ajax({
        url: "/image/child/detach.json",
        type: "POST",
        data: {
          "image_id": imageId,
          "child_id": childId,
          "XSRF-TOKEN": token
        },
        dataType: "json",
        success: function(response) {
          if (!response.rows || response.rows < 1) {
            showAttachedChild(childId);
          } else {
            removeAttachedChild(childId);
          }
          return refreshChildAttachedMark();
        },
        error: function() {
          showAttachedChild(childId);
          return refreshChildAttachedMark();
        }
      });
    };
    refreshChildAttachedMark = function() {
      var attachedChildren, child, childId, currentEntryIndex, _base3, _i, _len, _ref;
      currentEntryIndex = getCurrentEntryIndex();
      (_base3 = window.entryData.entries[currentEntryIndex]).child || (_base3.child = []);
      attachedChildren = {};
      _ref = window.entryData.entries[currentEntryIndex].child;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        childId = child.child_id;
        attachedChildren[childId] = true;
      }
      return $(".child-attach-item").each(function() {
        childId = $(this).attr("data-child-id");
        $(this).off("click");
        if (attachedChildren[childId]) {
          $(this).find(".child-attached-mark span").show();
          return $(this).on("click", detachChildFromImage);
        } else {
          return $(this).on("click", attachChildToImage);
        }
      });
    };
    showCarousel = function(params, addOnCallback) {
      var initial, offset;
      if (params.offset) {
        offset = params.offset;
        initial = "min";
      } else if (params.minIndex) {
        if (params.minIndex <= 10) {
          offset = 0;
          initial = "min";
        } else {
          offset = params.minIndex - 10;
          initial = "max";
        }
      } else if (params.maxIndex) {
        initial = "min";
        offset = params.maxIndex + 1;
      } else {
        return;
      }
      return getData(offset, initial, addOnCallback);
    };
    getCurrentEntryIndex = function() {
      var position;
      position = parseInt(owlObject.currentPosition(), 10);
      if ($($(".img-box")[0]).hasClass("moreImage")) {
        position = position - 1;
      }
      return position;
    };
    getCurrentPosition = function() {
      return parseInt(owlObject.currentPosition(), 10);
    };
    confirmRemoveImage = function() {
      var currentImgBox, currentPosition;
      currentPosition = getCurrentPosition();
      currentImgBox = $($(".img-box")[currentPosition]);
      if (currentImgBox.hasClass("moreImage")) {
        return;
      }
      return $("#remove-image-modal").modal({
        "data-backdrop": true
      });
    };
    return removeImage = function() {
      var currentImgBox, currentPosition, imageId, token;
      currentPosition = getCurrentPosition();
      currentImgBox = $($(".img-box")[currentPosition]);
      if (currentImgBox.hasClass("moreImage")) {
        return;
      }
      imageId = currentImgBox.attr("image-id");
      token = getXSRFToken();
      return $.ajax({
        type: "post",
        url: "image/web/remove.json",
        data: {
          image_id: imageId,
          "XSRF-TOKEN": token
        },
        dataType: "json",
        success: function(data) {
          var afterIndex, imgBoxes;
          owlObject.removeItem(currentPosition);
          imgBoxes = $(".img-box");
          afterIndex = $(".img-box")[currentPosition] != null ? $($(".img-box")[currentPosition]).hasClass("moreImage") ? currentPosition - 1 : currentPosition : currentPosition;
          owlObject.jumpTo(afterIndex);
          window.entryData.entries.splice(currentPosition, 1);
          return $("#remove-image-modal").modal("hide");
        },
        error: function() {}
      });
    };
  };

  window.util || (window.util = {});

  window.util.showImageDetail = showImageDetail;

}).call(this);

//# sourceMappingURL=../../static/js/detail.js.map
