(function() {
  var console;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  window.target_child_id;

  window.user_data = [];

  window.is_icon_changed = 0;

  window.new_icon;

  window.view_other_profile = 0;

  window.temp_url = "";

  $(function() {
    var $child_form, $user_form, getXSRFToken, grid_child, grid_relatives, grid_user, profile_get_url, showEditChildModal, showEditUserModal, showErrorMessage, tmpl_child, tmpl_new_child, tmpl_relatives, tmpl_user, uploadChildIcon, uploadUserIcon;
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
    tmpl_user = _.template($('#template-user-profile').html());
    tmpl_relatives = _.template($('#template-relatives-profile').html());
    tmpl_child = _.template($('#template-child-profile').html());
    tmpl_new_child = _.template($('#template-new-child-profile').html());
    grid_user = $('.user-timeline').get(0);
    grid_relatives = $('.relatives-timeline').get(0);
    grid_child = $('.child-timeline').get(0);
    profile_get_url = "/profile/get.json";
    if ($("#profile_js").attr("target_user_id")) {
      profile_get_url = "/profile/get.json?target_user_id=" + $("#profile_js").attr("target_user_id");
      window.view_other_profile = 1;
    }
    $.ajax({
      url: profile_get_url,
      success: function(data) {
        var HTML, i, visibility, _i, _j, _ref, _ref1, _results;
        window.user_data = data;
        visibility = "hidden";
        if (data.accessed_user_id === data.user_id) {
          visibility = "visible";
        }
        HTML = tmpl_user({
          url: data.icon_image_url,
          name: data.user_name,
          id: data.user_id,
          edit_visibility: visibility
        });
        $('#profile_user').append(HTML);
        $("#user_edit_button_" + data.user_id).on('click', function(e) {
          return showEditUserModal(e);
        });
        if (data.relatives.length > 0) {
          for (i = _i = 0, _ref = data.relatives.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            if (data.relatives[i].relative_name === "") {
              data.relatives[i].relative_name = "名無し";
            }
            HTML = tmpl_relatives({
              url: data.relatives[i].relative_icon_url,
              name: data.relatives[i].relative_name,
              id: data.relatives[i].relative_id
            });
            $('#profile_friend').append(HTML);
            $("#relative_panel_" + data.relatives[i].relative_id).on('click', function() {
              return location.href = "/profile?target_user_id=" + $(this).attr("relative_id");
            });
          }
        }
        if (window.view_other_profile !== 1) {
          HTML = tmpl_new_child({});
          $('#profile_child').append(HTML);
          $("#add-new-child-pannel").on('click', function(e) {
            window.target_child_id = "";
            return showEditChildModal(e);
          });
        }
        if (data.child.length > 0) {
          _results = [];
          for (i = _j = 0, _ref1 = data.child.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
            visibility = "hidden";
            if (data.child[i].created_by === data.accessed_user_id) {
              visibility = "visible";
            }
            HTML = tmpl_child({
              edit_visibility: visibility,
              name: data.child[i].child_name,
              id: data.child[i].child_id,
              url: data.child[i].child_icon_url,
              birth_year: data.child[i].child_birthday_year,
              birth_month: data.child[i].child_birthday_month,
              birth_day: data.child[i].child_birthday_day
            });
            $('#profile_child').append(HTML);
            _results.push($("#child_edit_button_" + data.child[i].child_id).on('click', function(e) {
              window.target_child_id = $(this).attr("child_id");
              return showEditChildModal(e);
            }));
          }
          return _results;
        }
      },
      error: function() {
        return window.console.log("error");
      }
    });
    showEditUserModal = function(e) {
      e.stopPropagation();
      $("#editUserModal").modal({
        "backdrop": true
      });
      $("#user_modal_user_name").attr("value", $('#user_profile_user_name').text());
      return $("#user_modal_user_icon").attr("src", $('#user_profile_user_icon').attr("src"));
    };
    showEditChildModal = function(e) {
      var elem, elems, i, options, time, year, _i, _j, _k, _l, _len, _len1, _len2, _m, _n, _results;
      e.stopPropagation();
      $("#editChildModal").modal({
        "backdrop": true
      });
      $("#child_modal_child_name").attr("value", $('#user_profile_child_name_' + window.target_child_id).text());
      $("#child_modal_child_icon").attr("src", $('#user_profile_child_icon_' + window.target_child_id).attr("src"));
      options = $("#child_birthday_year").find("option");
      if ($(options).length < 2) {
        time = new Date;
        year = time.getFullYear();
        for (i = _i = 2005; 2005 <= year ? _i <= year : _i >= year; i = 2005 <= year ? ++_i : --_i) {
          $('#child_birthday_year').append('<option value="' + i + '">' + i + '</option>');
        }
        for (i = _j = 1; _j <= 12; i = ++_j) {
          if (i < 10) {
            $('#child_birthday_month').append('<option value="0' + i + '">' + i + '</option>');
          } else {
            $('#child_birthday_month').append('<option value="' + i + '">' + i + '</option>');
          }
        }
        for (i = _k = 1; _k <= 31; i = ++_k) {
          if (i < 10) {
            $('#child_birthday_day').append('<option value="0' + i + '">' + i + '</option>');
          } else {
            $('#child_birthday_day').append('<option value="' + i + '">' + i + '</option>');
          }
        }
      }
      $("#child_birthday_year").val($('#user_profile_birth_year_' + window.target_child_id).text());
      elems = $("#child_birthday_year").find("option");
      for (_l = 0, _len = elems.length; _l < _len; _l++) {
        elem = elems[_l];
        if ($(elem).attr('value') === $('#user_profile_birth_year_' + window.target_child_id).text()) {
          $(elem).attr('selected', true);
          $(elem).trigger("change");
          break;
        }
      }
      $("#child_birthday_month").val($('#user_profile_birth_month_' + window.target_child_id).text());
      elems = $("#child_birthday_month").find("option");
      for (_m = 0, _len1 = elems.length; _m < _len1; _m++) {
        elem = elems[_m];
        if ($(elem).attr('value') === $('#user_profile_birth_month_' + window.target_child_id).text()) {
          $(elem).attr('selected', true);
          $(elem).trigger("change");
          break;
        }
      }
      $("#child_birthday_day").val($('#user_profile_birth_day_' + window.target_child_id).text());
      elems = $("#child_birthday_day").find("option");
      _results = [];
      for (_n = 0, _len2 = elems.length; _n < _len2; _n++) {
        elem = elems[_n];
        if ($(elem).attr('value') === $('#user_profile_birth_day_' + window.target_child_id).text()) {
          $(elem).attr('selected', true);
          $(elem).trigger("change");
          break;
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    $("#user_edit_submit").on('click', function(e) {
      var token;
      token = getXSRFToken();
      return $.ajax({
        "type": "post",
        "url": "/profile/edit_name.json",
        "data": {
          "user_id": window.user_data.user_id,
          "user_name": $("#user_modal_user_name").val(),
          "XSRF-TOKEN": token
        },
        "dataType": "json",
        "success": function() {
          if (window.is_icon_changed === 1) {
            uploadUserIcon(window.new_icon);
          }
          return $('#user_profile_user_name').text($("#user_modal_user_name").val());
        },
        "error": function() {}
      });
    });
    $("#child_edit_delete").on('click', function(e) {
      var token;
      token = getXSRFToken();
      if (window.target_child_id !== "") {
        return $.ajax({
          "type": "post",
          "url": "/profile/delete_child.json",
          "data": {
            "child_id": window.target_child_id,
            "XSRF-TOKEN": token
          },
          "dataType": "json",
          "success": function() {
            return $('#item_user_profile_child_icon_' + window.target_child_id).remove();
          },
          "error": function() {}
        });
      }
    });
    $("#child_edit_submit").on('click', function(e) {
      var token;
      token = getXSRFToken();
      if (window.target_child_id === "") {
        window.temp_url = "";
        return $.ajax({
          "type": "post",
          "url": "/profile/add_child.json",
          "data": {
            "child_name": $("#child_modal_child_name").val(),
            "birth_year": $("#child_birthday_year").val(),
            "birth_month": $("#child_birthday_month").val(),
            "birth_day": $("#child_birthday_day").val(),
            "XSRF-TOKEN": token
          },
          "dataType": "json",
          "success": function(response) {
            var HTML;
            if (window.is_icon_changed === 1) {
              window.target_child_id = response.id;
              uploadChildIcon(window.new_icon);
            } else {
              window.new_icon = "";
            }
            HTML = tmpl_child({
              edit_visibility: "visible",
              name: $("#child_modal_child_name").val(),
              id: response.id,
              url: window.new_icon,
              birth_year: $("#child_birthday_year").val(),
              birth_month: $("#child_birthday_month").val(),
              birth_day: $("#child_birthday_day").val()
            });
            $('#profile_child').append(HTML);
            return $("#child_edit_button_" + response.id).on('click', function(e) {
              window.target_child_id = $(this).attr("child_id");
              return showEditChildModal(e);
            });
          },
          "error": function() {}
        });
      } else {
        return $.ajax({
          "type": "post",
          "url": "/profile/edit_child.json",
          "data": {
            "child_id": window.target_child_id,
            "child_name": $("#child_modal_child_name").val(),
            "birth_year": $("#child_birthday_year").val(),
            "birth_month": $("#child_birthday_month").val(),
            "birth_day": $("#child_birthday_day").val(),
            "XSRF-TOKEN": token
          },
          "dataType": "json",
          "success": function() {
            if (window.is_icon_changed === 1) {
              uploadChildIcon(window.new_icon);
            }
            $('#user_profile_child_name_' + window.target_child_id).text($("#child_modal_child_name").val());
            $('#user_profile_birth_year_' + window.target_child_id).text($("#child_birthday_year").val());
            $('#user_profile_birth_month_' + window.target_child_id).text($("#child_birthday_month").val());
            return $('#user_profile_birth_day_' + window.target_child_id).text($("#child_birthday_day").val());
          },
          "error": function() {}
        });
      }
    });
    $(".user_modal_change_icon").on('click', function() {
      $("#user-image-post-form").find("[type=file]").trigger("click");
      return false;
    });
    $user_form = $("#user-image-post-form");
    $user_form.find("[type=file]").on("change", function() {
      var fd;
      window.is_icon_changed = 1;
      window.console.log("file changed");
      $("#user_modal_user_icon").attr("src", "/static/img/ajax-loader.gif");
      fd = new FormData($user_form[0]);
      $.ajax($user_form.attr("action"), {
        type: 'post',
        processData: false,
        contentType: false,
        data: fd,
        dataType: 'json',
        success: function(data) {
          window.console.log(data);
          window.new_icon = data.image_tmp_name;
          $("#user_modal_user_icon").attr("src", data.image_tmp_url);
          return window.temp_url = data.image_tmp_url;
        },
        error: showErrorMessage
      });
      return false;
    });
    $(".child_modal_change_icon").on('click', function() {
      $("#child-image-post-form").find("[type=file]").trigger("click");
      return false;
    });
    $child_form = $("#child-image-post-form");
    $child_form.find("[type=file]").on("change", function() {
      var fd;
      window.is_icon_changed = 1;
      window.console.log("file changed");
      $("#child_modal_child_icon").attr("src", "/static/img/ajax-loader.gif");
      fd = new FormData($child_form[0]);
      $.ajax($child_form.attr("action"), {
        type: 'post',
        processData: false,
        contentType: false,
        data: fd,
        dataType: 'json',
        success: function(data) {
          window.console.log(data);
          window.new_icon = data.image_tmp_name;
          $("#child_modal_child_icon").attr("src", data.image_tmp_url);
          return window.temp_url = data.image_tmp_url;
        },
        error: showErrorMessage
      });
      return false;
    });
    showErrorMessage = function(xhr, textStatus, errorThrown) {
      window.console.log("error");
      window.console.log(xhr.responseText);
      return window.alert(xhr.responseText);
    };
    uploadChildIcon = function(icon) {
      var token;
      token = getXSRFToken();
      window.console.log(window.target_child_id);
      return $.ajax("/image/web/submit.json", {
        type: "post",
        data: {
          "shared_user_ids": [],
          "image_tmp_names": [icon],
          "child_id": window.target_child_id,
          "XSRF-TOKEN": token
        },
        dataType: 'json',
        success: function() {
          window.console.log('icon submitted');
          return $('#user_profile_child_icon_' + window.target_child_id).attr("src", window.temp_url);
        },
        error: showErrorMessage
      });
    };
    return uploadUserIcon = function(icon) {
      var token;
      token = getXSRFToken();
      window.console.log(window.user_data.user_id);
      return $.ajax("/image/web/submit.json", {
        type: "post",
        data: {
          "shared_user_ids": [],
          "image_tmp_names": [icon],
          "is_icon": "1",
          "XSRF-TOKEN": token
        },
        dataType: 'json',
        success: function() {
          window.console.log('icon submitted');
          return $('#user_profile_user_icon').attr("src", window.temp_url);
        },
        error: showErrorMessage
      });
    };
  });

}).call(this);

//# sourceMappingURL=../../static/js/profile.js.map
