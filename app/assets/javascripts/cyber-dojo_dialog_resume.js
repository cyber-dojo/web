/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.reJoin = function(id, avatarName) {
    var url = '/kata/edit/' + id + '?avatar=' + avatarName;
    window.location.href = cd.homePageUrl(id);
    window.open(url);
  };

  cd.resumeDialog = function(title, dialogHtml) {
    var buttons = { };
    buttons['cancel'] = function() { $(this).dialog('close'); };
    $('<div class="dialog">')
      .html(dialogHtml)
      .dialog({
        title: cd.dialogTitle(title),
        autoOpen: true,
        width: 400,
        modal: true,
        buttons: buttons
      });
  };

  return cd;

})(cyberDojo || {}, jQuery);
