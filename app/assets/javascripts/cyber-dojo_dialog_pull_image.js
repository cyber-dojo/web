/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.dialog_pullImageIfNeededThen = function(dojoParams, from, fn) {
    $.getJSON('/image_puller/pulled', dojoParams, function(pulled) {
      if (!pulled.result) {
        dialog_pullImageThen(fn, dojoParams, from);
      } else {
        fn(dojoParams, from);
      }
    });
  };

  var dialog_pullImageThen = function(fn, dojoParams, from) {
    var title = 'setting up a new practice session...';
    var pullingDialog = makePullingDialog(title, dojoParams);
    pullingDialog.dialog('open');
    $.getJSON('/image_puller/pull', dojoParams, function(pull) {
      pullingDialog.dialog('close');
      if (pull.result) {
        fn(dojoParams, from);
      } else {
        makePullFailedDialog(title, dojoParams).dialog('open');
      }
    });
  };

  var makePullingDialog = function(title, dojoParams) {
    var html = '' +
      '<div class="selection">' + dojoParams.selection + '</div><br/>' +
      'First time for this selection!<br/>' +
      "We're now doing a one-time only setup.<br/>" +
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

  cd.chosenMajorMinor = function() {
    return {
      major: cd.chosenMajor(),
      minor: cd.chosenMinor()
    };
  };

  cd.chosenMajor = function() {
    return $('[id^=major_][class~=selected]').data('major');
  };

  cd.chosenMinor = function() {
    return $('[id^=minor_][class~=selected]').data('minor');
  };

  return cd;

})(cyberDojo || {}, jQuery);
