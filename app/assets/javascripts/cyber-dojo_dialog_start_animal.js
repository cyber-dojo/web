/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  const title = ''; // none

  cd.startAnimal = function(id, from) {
    $.getJSON('/enter/start', { id: id }, function(dojo) {
      if (dojo.full) {
        cd.dialog(dojo.full_dialog_html, title, 'ok').dialog('open');
      } else {
        startDialog(id, dojo.avatar_name, dojo.start_dialog_html, from);
      }
    });
  };

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
        title: cd.dialogTitle(title),
        autoOpen: true,
        width: 400,
        modal: true,
        closeOnEscape: true,
        close: function() { okOrCancel(); $(this).remove(); },
        buttons: { ok: function() { okOrCancel(); $(this).remove(); } }
      });
  };

  return cd;
})(cyberDojo || {}, jQuery);
