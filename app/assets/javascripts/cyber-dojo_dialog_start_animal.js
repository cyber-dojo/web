/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  const noTitle = '';

  const startDialog = function(id, avatarName, dialogHtml) {
    var url = '/kata/edit/' + id + '?avatar=' + avatarName;
    var okOrCancel = function() {
      window.location.href = cd.homePageUrl(id);
      window.open(url);
    };
    $('<div class="dialog">')
      .html(dialogHtml)
      .dialog({
        title: cd.dialogTitle(noTitle),
        autoOpen: true,
        width: 400,
        modal: true,
        closeOnEscape: true,
        close: function() { okOrCancel(); $(this).remove(); },
        buttons: { ok: function() { okOrCancel(); $(this).remove(); } }
      });
  };

  cd.startAnimal = function(id) {
    $.getJSON('/enter/start', { id: id }, function(dojo) {
      if (dojo.full) {
        cd.dialog(dojo.full_dialog_html, noTitle, 'ok').dialog('open');
      } else {
        startDialog(id, dojo.avatar_name, dojo.start_dialog_html);
      }
    });
  };

  return cd;
})(cyberDojo || {}, jQuery);
