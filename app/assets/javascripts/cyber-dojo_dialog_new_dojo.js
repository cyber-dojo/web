/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.newDojoDialog = function(dojoParams, from) {
    $.getJSON('/image_puller/image_pulled', dojoParams, function(pulled) {
      if (!pulled.result) {
        dialog_pullImage(dojoParams, from);
      } else {
        showNewDojoDialog(dojoParams, from);
      }
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - -

  var dialog_pullImage = function(dojoParams, from) {
    var title = 'setting up a new practice session...';
    var pullingDialog = makePullingDialog(title, dojoParams);
    pullingDialog.dialog('open');
    $.getJSON('/image_puller/image_pull', dojoParams, function(pull) {
      pullingDialog.dialog('close');
      if (pull.result) {
        showNewDojoDialog(dojoParams, from);
      } else {
        makePullFailedDialog(title, dojoParams).dialog('open');
      }
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - -

  var makePullingDialog = function(title, dojoParams) {
    var html = '' +
      '<div class="selection">' + dojoParams.display_name + '</div><br/>' +
      'First time for this selection!<br/>' +
      "Doing a one-time only setup.<br/>" +
      'It can take a minute or two.<br/>' +
      'Please wait...';
    return $('<div id="setup-pull-dialog">')
      .html(avatarGridTable(html))
      .dialog({
        title: cd.dialogTitle(title),
        closeOnEscape: true,
        close: function() { $(this).remove(); },
        autoOpen: false,
        width: 620,
        height: 230,
        modal: true,
      });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - -

  var makePullFailedDialog = function(title, dojoParams) {
    var html = '' +
      "We're very sorry...<br/>" +
      'The setup failed.<br/>';
    return $('<div id="setup-pull-dialog">')
      .html(avatarGridTable(html))
      .dialog({
        title: cd.dialogTitle(title),
        closeOnEscape: true,
        close: function() { $(this).remove(); },
        autoOpen: false,
        buttons: {
          'close': function() {
            $(this).remove();
          }
        },
        width: 620,
        height: 310,
        modal: true,
      });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - -

  var avatarGridTable = function(rhs) {
    return '' +
      '<table>' +
      '<tr>' +
      '<td>' +
      '<img src="/images/avatars/all_avatars_background.png" class="avatars-grid">' +
      '</td>' +
      '<td>' +
      rhs +
      '</td>' +
      '</tr>' +
      '</table>';
  };

  //- - - - - - - - - - - - - - - - - - - - - - - -

  var showNewDojoDialog = function(params, from) {
    var id = params['id'];

    if (from == 'from_setup_team') {
      window.location = '/enter/show/' + id;
      return;
    }
    if (from == 'from_setup_individual') {
      cd.startAnimal(id, 'from_setup');
      return;
    }


    var gotoPage = function(url) {
      if (from == 'from_setup') {
        window.location = url; // same tab
      }
      if (from == 'from_fork') {
        window.open(url); // new tab
      }
    };

    var html = '' +
      "<div class='align-center'>" +
        "<div class='avatar-background'>" +
          "<span class='dojo-id'>" +
            id.substring(0,6) +
          '</span>' +
        '</div>' +
      '</div>';

    $('<div>')
      .html(html)
      .dialog({
        title: cd.dialogTitle('setup&nbsp;a&nbsp;new&nbsp;practice&nbsp;session'),
        autoOpen: true,
        modal: true,
        width: 435,
        closeOnEscape: true,
        open: function() {
          var pane = $('.ui-dialog-buttonpane');
          pane.find('button:contains("goto home page")').addClass('new-dojo-dialog-button enter-page');
          pane.find('button:contains("start programming")').addClass('new-dojo-dialog-button start-coding');
        },
        close: function() {
          $(this).remove();
        },
        buttons: {
          'goto home page': function() {
            gotoPage('/dojo/index/' + id);
            $(this).remove();
          },
          'start programming': function() {
            cd.startAnimal(id, from);
            $(this).remove();
          }
        }
      });
  };

  return cd;

})(cyberDojo || {}, jQuery);
