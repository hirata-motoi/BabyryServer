(function() {
  var console;

  if (typeof window.console === "undefined") {
    console = {};
    console.log = console.warn = console.error = function(a) {};
  }

  window.target_child_id;

  window.child_data = [];

  window.is_icon_changed = 0;

  window.new_icon;

  $(function() {
    var $form, getXSRFToken, grid_child, grid_user, showEditChildModal, showErrorMessage, tmpl_child, tmpl_new_child, tmpl_user, uploadChildIcon;
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
    tmpl_child = _.template($('#template-child-profile').html());
    tmpl_new_child = _.template($('#template-new-child-profile').html());
    grid_user = $('.user-timeline').get(0);
    grid_child = $('.child-timeline').get(0);
    $.ajax({
      url: '/profile/get.json',
      success: function(data) {
        var child_item, i, user_item, _i, _j, _ref, _ref1;
        user_item = [];
        user_item.push(document.createElement('article'));
        salvattore.append_elements(grid_user, user_item);
        user_item[0].outerHTML = tmpl_user({
          url: data.icon_image_url,
          name: data.user_name
        });
        child_item = [];
        for (i = _i = 0, _ref = data.child.length; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          child_item.push(document.createElement('article'));
        }
        salvattore.append_elements(grid_child, child_item);
        if (data.child.length > 0) {
          for (i = _j = 0, _ref1 = data.child.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
            child_item[i].outerHTML = tmpl_child({
              name: data.child[i].child_name,
              id: data.child[i].child_id,
              url: data.child[i].child_icon_url,
              birth_year: data.child[i].child_birthday_year,
              birth_month: data.child[i].child_birthday_month,
              birth_day: data.child[i].child_birthday_day
            });
            window.child_data[data.child[i].child_id] = data.child[i];
            $("#child_edit_button_" + data.child[i].child_id).on('click', function(e) {
              window.target_child_id = $(this).attr("child_id");
              return showEditChildModal(e);
            });
          }
        }
        child_item[data.child.length].outerHTML = tmpl_new_child({});
        return $("#add-new-child-pannel").on('click', function(e) {
          window.target_child_id = "";
          return showEditChildModal(e);
        });
      },
      error: function() {
        return window.console.log("error");
      }
    });
    showEditChildModal = function(e) {
      var data, i, time, year, _i, _j, _k;
      e.stopPropagation();
      $("#editChildModal").modal({
        "backdrop": true
      });
      if (window.target_child_id === "") {
        $("#child_modal_child_name").attr("value", "");
        $("#child_modal_child_icon").attr("src", "/static/img/160x160.png");
      } else {
        data = window.child_data[window.target_child_id];
        $("#child_modal_child_name").attr("value", data.child_name);
        $("#child_modal_child_icon").attr("src", data.child_icon_url);
      }
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
      if (window.target_child_id !== "") {
        $("#child_birthday_year").val(data.child_birthday_year);
        $("#child_birthday_month").val(data.child_birthday_month);
        return $("#child_birthday_day").val(data.child_birthday_day);
      } else {
        $("#child_birthday_year").val("----");
        $("#child_birthday_month").val("--");
        return $("#child_birthday_day").val("--");
      }
    };
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
            return location.reload(true);
          },
          "error": function() {}
        });
      }
    });
    $("#child_edit_submit").on('click', function(e) {
      var token;
      token = getXSRFToken();
      if (window.target_child_id === "") {
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
            if (window.is_icon_changed === 1) {
              window.target_child_id = response.id;
              return uploadChildIcon(window.new_icon);
            } else {
              return location.reload(true);
            }
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
              return uploadChildIcon(window.new_icon);
            } else {
              return location.reload(true);
            }
          },
          "error": function() {}
        });
      }
    });
    $("#child_modal_change_icon").on('click', function() {
      $("#image-post-form").find("[type=file]").trigger("click");
      return false;
    });
    $form = $("#image-post-form");
    $form.find("[type=file]").on("change", function() {
      var fd;
      window.is_icon_changed = 1;
      window.console.log("file changed");
      $("#child_modal_child_icon").attr("src", "/static/img/ajax-loader.gif");
      fd = new FormData($form[0]);
      $.ajax($form.attr("action"), {
        type: 'post',
        processData: false,
        contentType: false,
        data: fd,
        dataType: 'json',
        success: function(data) {
          window.console.log(data);
          window.new_icon = data.image_tmp_name;
          return $("#child_modal_child_icon").attr("src", data.image_tmp_url);
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
    return uploadChildIcon = function(icon) {
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
          return location.reload(true);
        },
        error: showErrorMessage
      });
    };
  });

}).call(this);

//# sourceMappingURL=../../static/js/profile.js.map
