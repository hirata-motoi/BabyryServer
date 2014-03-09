(function() {
  var console, showImageDetail, _base, _base1;

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

  window.entryIdsInArray = [];

  window.loadingFlg = false;

  showImageDetail = function() {
    var alreadyAttachedStamp, attachStamp, createImageBox, createStampAttachIcon, getCurrentEntryId, getData, getNextIds, getStampData, getStampHash, getXSRFToken, hasElem, pickData, preserveResponseData, setStampAttachList, setStampsByImagePosition, shouldPreLoad, showEntries, showErrorMessage, showLoadingImage, upsertStampsByImagePosition;
    $(".img-thumbnail").on("click", function() {
      var $elem, data, i, imageId, image_id, image_url, initialIndex, n, owlContainer, stampElem, stampImage, stampInfo, stampList, stamps, _i, _j, _len, _ref;
      imageId = $(this).parents(".item").attr("image_id");
      data = pickData();
      upsertStampsByImagePosition(data.list);
      owlContainer = $(".owl-carousel").clone(true);
      owlContainer.addClass("displayed");
      for (i = _i = 0, _ref = data.found_row_count - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (data.list[i]) {
          image_url = data.list[i].fullsize_image_url;
          window.entryIdsInArray.push(data.list[i].image_id);
          stamps = data.list[i].stamps;
          image_id = data.list[i].image_id;
        } else {
          image_url = "";
          image_id = "";
        }
        $elem = createImageBox(image_url, image_id);
        owlContainer.append($elem);
        if (data.list[i] && data.list[i].image_id === imageId) {
          initialIndex = i;
        }
        if (stamps) {
          stampList = [];
          for (n = _j = 0, _len = stamps.length; _j < _len; n = ++_j) {
            stampInfo = stamps[n];
            stampElem = $("<a>");
            stampElem.addClass("stamp");
            stampImage = $("<img>");
            stampImage.addClass("stamp-icon");
            stampImage.attr("src", stampInfo.icon_url);
            stampElem.append(stampImage);
            $elem.find(".stamp-container").append(stampElem);
          }
        }
      }
      $(".dynamic-container").html(owlContainer);
      $(".owl-carousel.displayed").owlCarousel({
        items: 1,
        scrollPerPage: true,
        beforeInit: function() {},
        beforeMove: function() {},
        afterMove: function() {
          var count, currentPageNo, loadingFlg;
          if (shouldPreLoad(5)) {
            if (window.loadingFlg) {
              return;
            }
            currentPageNo = 1;
            count = 10;
            showLoadingImage();
            loadingFlg = true;
            /*
            $.ajax({
              "url": "/entry/search.json",
              "processData": true,
              "contentType": false,
              "data": {
                "page": currentPageNo + 1,
                "count": count,
              },
              "dataType": 'json',
              "success": showEntries,
              "error": showErrorMessage
            })
            */

            return getData(showEntries, showErrorMessage);
          }
        }
      });
      return $(".stamp-attach-icon").on("click", attachStamp);
    });
    shouldPreLoad = function(num) {
      var owl;
      owl = $(".owl-carousel").data('owlCarousel');
      if (window.entryIdsInArray.length < owl.currentPosition() + num) {
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
          "page": nextPage,
          "count": countPerPage
        },
        "dataType": 'json',
        "success": successCallback,
        "error": errorCallback
      });
    };
    createImageBox = function(image_url, image_id) {
      var owlElem, tmpl;
      tmpl = $("#item-tmpl").clone(true);
      owlElem = $(tmpl);
      owlElem.find(".img-box").attr("image-id", image_id);
      owlElem.find(".img-box img").attr("src", image_url);
      owlElem.attr("id", "");
      if (!image_url) {
        owlElem.addClass("unloaded");
      }
      owlElem.show();
      return owlElem;
    };
    showLoadingImage = function() {
      return $(".unloadedElems").first().find(".img-box img").attr("src", "/static/img/ajax-loader.gif");
    };
    showErrorMessage = function() {};
    showEntries = function(response) {
      var elem, i, image_url, owl, unloadedElems, _i, _len;
      if (response.data.entries.length < 1) {
        return;
      }
      preserveResponseData(response);
      owl = $(".owl-carousel").data('owlCarousel');
      unloadedElems = $(".unloaded");
      for (i = _i = 0, _len = unloadedElems.length; _i < _len; i = ++_i) {
        elem = unloadedElems[i];
        if (response.data.entries[i]) {
          image_url = response.data.entries[i].fullsize_image_url;
          $(elem).find(".img-box img").attr("src", image_url);
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
    attachStamp = function() {
      var currentPosition, imageId, owl, stampElem, stampHash, stampIconUrl, stampId, stampImage, targetImgBox, token;
      stampId = $(this).attr("stamp-id");
      owl = $(".owl-carousel").data('owlCarousel');
      currentPosition = owl.currentPosition();
      if (alreadyAttachedStamp(stampId, currentPosition)) {
        return;
      }
      stampHash = getStampHash();
      stampIconUrl = stampHash[stampId].icon_url;
      targetImgBox = $(".img-box")[currentPosition];
      imageId = $(targetImgBox).attr("image-id");
      stampElem = $("<a>");
      stampElem.addClass("stamp");
      stampImage = $("<img>");
      stampImage.addClass("stamp-icon");
      stampImage.attr("src", stampIconUrl);
      stampElem.append(stampImage);
      $(targetImgBox).find(".stamp-container").append(stampElem);
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
            return stampsByImagePosition[currentPosition][stampId] = false;
          }
        }
      });
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
        _results.push($("#stampAttachModal").find(".modal-body").append(elem));
      }
      return _results;
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
      window.stampData = response.data;
      return setStampAttachList();
    }
  };

  window.util = [];

  window.util.showImageDetail = showImageDetail;

}).call(this);

//# sourceMappingURL=../../static/js/detail.js.map
