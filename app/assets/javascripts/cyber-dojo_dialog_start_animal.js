/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  var startDialog = function(id, avatarName, dialogHtml, from) {
    var url = '/kata/edit/' + id + '?avatar=' + avatarName;
    var okOrCancel = function() {
      if (from == 'from_setup') {
        window.location = cd.homePageUrl(id);
      }
      window.open(url);
    };
    $('<div class="dialog">')
      .html(dialogHtml)
      .dialog({
        title: cd.dialogTitle('start'),
        autoOpen: true,
        width: 350,
        modal: true,
        closeOnEscape: true,
        close: function() { okOrCancel(); $(this).remove(); },
        buttons: { ok: function() { okOrCancel(); $(this).remove(); } }
      });
  };

  cd.startAnimal = function(id, from) {
    $.getJSON('/enter/start', { id: id }, function(dojo) {
      if (dojo.full) {
        cd.dialog(dojo.full_dialog_html, 'start', 'ok').dialog('open');
      } else {
        startDialog(id, dojo.avatar_name, dojo.start_dialog_html, from);
      }
    });
  };

  return cd;
})(cyberDojo || {}, jQuery);
