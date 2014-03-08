(function() {
  var console, entryIdsInArray, loadingFlg;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  $(function() {});

  /*
  set event to click each image
  this part will be replaced by methods in entries.coffee
  */


  entryIdsInArray = [];

  loadingFlg = false;

  $(function() {
    var createImageBox, getCurrentEntryId, getData, getNextIds, preserveResponseData, shouldPreLoad, showEntries, showErrorMessage, showLoadingImage;
    $(".img-thumbnail").on("click", function() {
      var data, elem, i, imageId, image_url, initialIndex, owlContainer, _i, _ref;
      imageId = $(this).parents(".item").attr("image_id");
      data = getData(preserveResponseData, showErrorMessage, true);
      window.console.log(data.list);
      owlContainer = $(".owl-carousel").clone(true);
      owlContainer.addClass("displayed");
      for (i = _i = 0, _ref = data.found_row_count - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (data.list[i]) {
          window.console.log(data.list[i]);
          image_url = data.list[i].fullsize_image_url;
          entryIdsInArray.push(data.list[i].image_id);
        } else {
          image_url = "";
        }
        elem = createImageBox(image_url);
        owlContainer.append(elem);
        if (data.list[i] && data.list[i].image_id === imageId) {
          initialIndex = i;
        }
      }
      window.console.log(initialIndex);
      $(".dynamic-container").html(owlContainer);
      return $(".owl-carousel.displayed").owlCarousel({
        items: 1,
        scrollPerPage: true,
        beforeInit: function() {},
        beforeMove: function() {},
        afterMove: function() {
          var count, currentPageNo;
          if (shouldPreLoad(5)) {
            window.console.log("shouldPreLoad is true");
            if (loadingFlg) {
              return;
            }
            currentPageNo = 1;
            count = 10;
            showLoadingImage();
            loadingFlg = true;
            /*
            $.ajax("/entry/search.json", {
              processData: true,
              contentType: false,
              data: {
                "page": currentPageNo + 1,
                "count": count,
              },
              dataType: 'json',
              success: showEntries,
              error: showErrorMessage
            })
            */

            return getData(showEntries, showErrorMessage, false);
          } else {
            return window.console.log("shouldPreLoad is false");
          }
        }
      });
    });
    shouldPreLoad = function(num) {
      var owl;
      owl = $(".owl-carousel").data('owlCarousel');
      window.console.log("currentPosition : " + owl.currentPosition());
      if (entryIdsInArray.length < owl.currentPosition() + num) {
        return true;
      } else {
        return false;
      }
    };
    preserveResponseData = function(response) {
      var entry, _base, _i, _len, _ref;
      window.entryData || (window.entryData = {});
      (_base = window.entryData).entries || (_base.entries = []);
      _ref = response.data.entries;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        entry = _ref[_i];
        window.entryData.entries.push(entry);
      }
      return window.entryData.metadata = response.metadata;
    };
    getData = function(successCallback, errorCallback, tempNotAsyncFlg) {
      var countPerPage, nextPage, _base;
      window.entryData || (window.entryData = {});
      (_base = window.entryData).metadata || (_base.metadata = {});
      nextPage = window.entryData.metadata.page ? parseInt(window.entryData.metadata.page, 10) + 1 : 1;
      countPerPage = window.entryData.metadata.count || 10;
      $.ajax("/entry/search.json", {
        async: !tempNotAsyncFlg,
        processData: true,
        contentType: false,
        data: {
          "page": nextPage,
          "count": countPerPage
        },
        dataType: 'json',
        success: successCallback,
        error: errorCallback
      });
      return {
        list: window.entryData.entries,
        found_row_count: window.entryData.metadata.found_row_count
      };
    };
    createImageBox = function(image_url) {
      var owlElem, tmpl;
      tmpl = $("#item-tmpl").clone(true);
      owlElem = $(tmpl);
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
      window.console.log(response);
      if (response.data.entries.length < 1) {
        return;
      }
      preserveResponseData(response);
      owl = $(".owl-carousel").data('owlCarousel');
      unloadedElems = $(".unloaded");
      for (i = _i = 0, _len = unloadedElems.length; _i < _len; i = ++_i) {
        elem = unloadedElems[i];
        if (response.data.entries[i]) {
          window.console.log(response.data.entries[i]);
          window.console.log(elem);
          image_url = response.data.entries[i].fullsize_image_url;
          $(elem).find(".img-box img").attr("src", image_url);
          $(elem).find(".loading").removeClass("loading");
          $(elem).removeClass("unloaded");
          entryIdsInArray.push(response.data.entries[i].image_id);
        } else {
          loadingFlg = false;
          break;
        }
      }
      return loadingFlg = false;
    };
    getNextIds = function() {
      var currentEntryId;
      return currentEntryId = getCurrentEntryId;
    };
    return getCurrentEntryId = function() {};
  });

}).call(this);

//# sourceMappingURL=../../static/js/detail.js.map
