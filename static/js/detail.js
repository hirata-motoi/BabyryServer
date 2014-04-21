(function() {
  var console, defaultTextareaHeight, innerHeight, innerWidth, owlObject, showImageDetail, _base, _base1, _base2;

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

  (_base2 = window.entryData).related_children || (_base2.related_children = {});

  window.childrenData || (window.childrenData = {});

  window.child_ids || (window.child_ids = []);

  window.entryIdsInArray = [];

  window.loadingFlg = false;

  window.displayedElementsFlg = true;

  owlObject = void 0;

  defaultTextareaHeight = "30px";

  innerWidth = 0;

  innerHeight = 0;

  showImageDetail = function() {
    var addChildToEntryData, adjustDisplayedElements, alreadyAttachedChild, attachChildToImage, backToWall, closeComments, createChild, createCommentNavigation, createImageBox, createOwlElements, detachChildFromImage, editChild, getData, getXSRFToken, hasElem, hideAttachedChild, initEditChild, lazyLoad, lazyRelease, pickData, preserveResponseData, refreshChildAttachedMark, releaseTargetElems, removeAttachedChild, replaceCarousel, replaceToolBoxContent, setChildAttachList, setUpScreenSize, setupGlobalFooter, shouldPreLoad, showAttachedChild, showComments, showEntries, showErrorMessage, showLoadingImage, showNavBarFooter, toggleDisplayedElements;
    $(".img-thumbnail").on("click", function() {
      var data, imageId, initialIndex, owlContainer, ret, tappedEntryIndex;
      setUpScreenSize();
      setupGlobalFooter();
      window.util.showPageLoading();
      $(".container").addClass("full-size-screen");
      innerWidth = window.innerWidth;
      innerHeight = window.innerHeight;
      $(".container.content-body").css("width", innerWidth);
      $(".container.content-body").css("height", innerHeight);
      imageId = $(this).parents(".item").attr("image_id");
      data = pickData();
      tappedEntryIndex = $(this).attr("entryIndex");
      ret = createOwlElements(tappedEntryIndex);
      owlContainer = ret.owlContainer;
      initialIndex = ret.initialIndex;
      $("#navbar-space").hide();
      $(".dynamic-container").html(owlContainer);
      $(window).scrollTop(0);
      $(".owl-carousel.displayed").owlCarousel({
        items: 1,
        pagination: false,
        scrollPerPage: true,
        afterMove: function() {
          var currentPosition, imageBoxes;
          currentPosition = owlObject.currentPosition();
          imageBoxes = $(".img-box");
          return replaceToolBoxContent();
        }
      });
      owlObject = $(".owl-carousel.displayed").data("owlCarousel");
      owlObject.jumpTo(initialIndex);
      window.util.hidePageLoading();
      showNavBarFooter();
      return setChildAttachList(data.related_children);
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
          $("#comment-textarea").css("height", defaultTextareaHeight);
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
      window.entryData.entries = response.data.entries;
      window.entryData.metadata = response.metadata;
      return window.entryData.related_children = response.related_children;
    };
    pickData = function() {
      return {
        list: window.entryData.entries,
        found_row_count: window.entryData.metadata.found_row_count,
        related_children: window.entryData.related_children
      };
    };
    getData = function(offset, initial, successCallback, errorCallback) {
      var countPerPage, nextPage;
      nextPage = window.entryData.metadata.page ? parseInt(window.entryData.metadata.page, 10) + 1 : 1;
      countPerPage = window.entryData.metadata.count || 10;
      return $.ajax({
        "url": "/entry/search.json",
        "processData": true,
        "contentType": false,
        "data": {
          "child_id": window.child_ids,
          "page": nextPage,
          "count": countPerPage,
          "offset": offset
        },
        "dataType": 'json',
        "success": function(response) {
          return successCallback(response, initial);
        },
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
    showEntries = function(response, initial) {
      var initialIndex, owlContainer, ret;
      if (response.data.entries.length < 1) {
        return;
      }
      preserveResponseData(response);
      initialIndex = initial === "max" ? response.data.entries.length - 1 : 0;
      ret = createOwlElements(initialIndex);
      owlContainer = ret.owlContainer;
      initialIndex = ret.initialIndex;
      $(".dynamic-container").html(owlContainer);
      return $(".owl-carousel.displayed").owlCarousel({
        items: 1,
        pagination: false,
        scrollPerPage: true,
        afterMove: function() {
          return replaceToolBoxContent();
        }
      });
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
      var childContainer, commentCount, commentCountText, commentItem, comments, currentPosition, elems;
      currentPosition = parseInt(owlObject.currentPosition(), 10);
      elems = $(".img-box");
      childContainer = $($(elems)[currentPosition]).find(".child-container").clone(true);
      $("#child-tag-container").find("ul").html(childContainer.html());
      $("#recent-comment-container").empty();
      comments = window.entryData.entries[currentPosition].comments;
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
      return $("#comment-count").text(commentCountText);
    };
    createCommentNavigation = function(comment_count) {
      return "コメント" + comment_count + "件";
    };
    showNavBarFooter = function() {
      $("#comment-count").on("click", showComments);
      $("#comment-edit-icon").on("click", showComments);
      $("#child-edit-icon").on("click", editChild);
      $("#modal-header").on("click", closeComments);
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
      var child, childHash, currentPosition, _base3, _i, _len, _ref;
      currentPosition = parseInt(owlObject.currentPosition(), 10);
      (_base3 = window.entryData.entries[currentPosition]).child || (_base3.child = []);
      childHash = {};
      _ref = window.entryData.entries[currentPosition].child;
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
        return $("#child-message-container").show();
      }
    };
    setupGlobalFooter = function() {
      return $("#global-footer").hide();
    };
    setChildAttachList = function(related_children) {
      var child, child_id, child_name, icon_url, item, itemObj, tmpl, _i, _len, _results;
      if (!related_children || related_children.length < 1) {
        return;
      }
      _results = [];
      for (_i = 0, _len = related_children.length; _i < _len; _i++) {
        child = related_children[_i];
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
      var childElem, childId, childName, currentPosition, imageElem, imageId, token;
      childId = $(this).attr("data-child-id");
      childName = $(this).find(".child-name").text();
      currentPosition = owlObject.currentPosition();
      imageElem = $(".img-box")[currentPosition];
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
      var child, childTags, children, currentPosition, index, length, tag, _i, _j, _len, _ref, _results;
      childTags = $("#child-tag-container").find(".child-tag-li");
      for (_i = 0, _len = childTags.length; _i < _len; _i++) {
        tag = childTags[_i];
        if (childId === $(tag).attr("data-child-id")) {
          $(tag).remove();
        }
      }
      currentPosition = owlObject.currentPosition();
      $($(".img-box")[currentPosition]).find(".child-tag-li").each(function() {
        if (childId === $(this).attr("data-child-id")) {
          return $(this).remove();
        }
      });
      children = window.entryData.entries[currentPosition].child;
      length = children.length;
      _results = [];
      for (index = _j = _ref = length - 1; _ref <= 0 ? _j <= 0 : _j >= 0; index = _ref <= 0 ? ++_j : --_j) {
        child = children[index];
        if (child.child_id === childId) {
          _results.push(children.splice(index, 1));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    alreadyAttachedChild = function(childId) {
      var child, children, currentPosition, index, _base3, _i, _len;
      currentPosition = owlObject.currentPosition();
      (_base3 = window.entryData.entries[currentPosition]).child || (_base3.child = []);
      children = window.entryData.entries[currentPosition].child;
      for (index = _i = 0, _len = children.length; _i < _len; index = ++_i) {
        child = children[index];
        if (child.child_id === childId) {
          return true;
        }
      }
    };
    addChildToEntryData = function(childId, childName) {
      var currentPosition, _base3;
      currentPosition = owlObject.currentPosition();
      (_base3 = window.entryData.entries[currentPosition]).child || (_base3.child = []);
      if (alreadyAttachedChild(childId)) {
        return false;
      }
      window.entryData.entries[currentPosition].child.push({
        "child_id": childId,
        "child_name": childName
      });
      return true;
    };
    detachChildFromImage = function() {
      var childId, childName, currentPosition, imageElem, imageId, token;
      childId = $(this).attr("data-child-id");
      childName = $(this).find(".child-name").text();
      currentPosition = owlObject.currentPosition();
      imageElem = $(".img-box")[currentPosition];
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
            refreshChildAttachedMark();
            return;
          }
          removeAttachedChild(childId);
          return refreshChildAttachedMark();
        },
        error: function() {
          showAttachedChild(childId);
          return refreshChildAttachedMark();
        }
      });
    };
    refreshChildAttachedMark = function() {
      var attachedChildren, child, childId, currentPosition, _base3, _i, _len, _ref;
      currentPosition = owlObject.currentPosition();
      (_base3 = window.entryData.entries[currentPosition]).child || (_base3.child = []);
      attachedChildren = {};
      _ref = window.entryData.entries[currentPosition].child;
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
    lazyLoad = function(imageElem) {
      var imageUrl;
      imageUrl = $(imageElem).attr("data-image-url");
      window.console.log("imageUrl : " + imageUrl);
      return $(imageElem).css("background-image", "url(" + imageUrl + ")");
    };
    lazyRelease = function(imageElems) {
      var elem, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = imageElems.length; _i < _len; _i++) {
        elem = imageElems[_i];
        window.console.log("release imageElem : " + elem);
        _results.push($(elem).css("background-image", ""));
      }
      return _results;
    };
    releaseTargetElems = function(imageBoxes, currentPosition) {
      var length, maxIndex, minIndex, targetElems, targetOverIndex, targetUnderIndex;
      length = imageBoxes.length;
      maxIndex = length - 1;
      minIndex = 0;
      targetOverIndex = parseInt(currentPosition, 10) + 3;
      targetUnderIndex = parseInt(currentPosition, 10) - 3;
      window.console.log("targetOverIndex : " + targetOverIndex);
      targetElems = [];
      if (targetOverIndex <= maxIndex) {
        targetElems.push(imageBoxes[targetOverIndex]);
      }
      if (targetUnderIndex >= minIndex) {
        targetElems.push(imageBoxes[targetUnderIndex]);
      }
      return targetElems;
    };
    createOwlElements = function(tappedEntryIndex) {
      var $elem, buttonAfter, buttonBefore, childElem, childInfo, childList, comment_count, count, data, i, image_id, image_url, initialIndex, maxIndex, minIndex, moreImageAfter, moreImageAfterElem, moreImageBefore, moreImageBeforeElem, n, owlContainer, _i, _j, _len;
      data = pickData();
      count = data.found_row_count;
      if (count <= 10) {
        minIndex = 0;
        maxIndex = data.found_row_count - 1;
        initialIndex = tappedEntryIndex;
        moreImageBefore = false;
        moreImageAfter = false;
      } else if (tappedEntryIndex < 5) {
        minIndex = 0;
        maxIndex = minIndex + 9;
        initialIndex = tappedEntryIndex;
        moreImageBefore = false;
        moreImageAfter = true;
      } else if (count - 6 <= tappedEntryIndex) {
        maxIndex = count - 1;
        minIndex = maxIndex - 9;
        initialIndex = tappedEntryIndex - 5 + 1;
        moreImageBefore = true;
        moreImageAfter = false;
      } else {
        initialIndex = 4 + 1;
        minIndex = tappedEntryIndex - 4;
        maxIndex = minIndex + 9;
        moreImageBefore = true;
        moreImageAfter = true;
      }
      owlContainer = $(".owl-carousel.template").clone(true);
      owlContainer.removeClass("template");
      owlContainer.addClass("displayed");
      if (moreImageBefore) {
        moreImageBeforeElem = createImageBox("/static/img/stamp/icon/1.jpeg", 0, 0, innerWidth, innerHeight);
        buttonBefore = $("<button>").text("more images");
        buttonBefore.on("click", function() {
          return replaceCarousel({
            minIndex: minIndex
          });
        });
        moreImageBeforeElem.find(".img-box").append(buttonBefore);
        owlContainer.append(moreImageBeforeElem);
      }
      for (i = _i = minIndex; minIndex <= maxIndex ? _i <= maxIndex : _i >= maxIndex; i = minIndex <= maxIndex ? ++_i : --_i) {
        if (data.list[i]) {
          image_url = data.list[i].fullsize_image_url;
          window.entryIdsInArray = [];
          window.entryIdsInArray.push(data.list[i].image_id);
          childList = data.list[i].child;
          image_id = data.list[i].image_id;
          comment_count = data.list[i].comments.length;
          $elem = createImageBox(image_url, image_id, comment_count, innerWidth, innerHeight);
          owlContainer.append($elem);
          if (childList) {
            for (n = _j = 0, _len = childList.length; _j < _len; n = ++_j) {
              childInfo = childList[n];
              childElem = createChild(childInfo.child_id, childInfo.child_name);
              $elem.find(".child-container").append(childElem);
            }
          }
          $elem.find(".child-container").hide();
        }
      }
      if (moreImageAfter) {
        moreImageAfterElem = createImageBox("/static/img/stamp/icon/1.jpeg", 0, 0, innerWidth, innerHeight);
        buttonAfter = $("<button>").text("more images");
        window.console.log(buttonAfter);
        buttonAfter.on("click", function() {
          return replaceCarousel({
            maxIndex: maxIndex
          });
        });
        moreImageAfterElem.find(".img-box").append(buttonAfter);
        owlContainer.append(moreImageAfterElem);
      }
      return {
        initialIndex: initialIndex,
        owlContainer: owlContainer
      };
    };
    return replaceCarousel = function(params) {
      var initial, offset;
      if (params.minIndex) {
        initial = "max";
        if (params.minIndex <= 10) {
          offset = 0;
        } else {
          offset = params.minIndex - 10;
        }
      } else if (params.maxIndex) {
        initial = "min";
        offset = params.maxIndex + 1;
      } else {
        return;
      }
      return getData(offset, initial, showEntries, showErrorMessage);
    };
  };

  window.util || (window.util = {});

  window.util.showImageDetail = showImageDetail;

}).call(this);

//# sourceMappingURL=../../static/js/detail.js.map
