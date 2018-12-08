/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.dialogTitle = (title) => {
    return `<span class="large dialog title">${title}<span>`;
  };

  cd.dialog = function(html, title, close) {
    let buttons = {};
    buttons[close] = function() { $(this).remove(); };
    return $('<div>')
      .html(html)
      .dialog({
        title: cd.dialogTitle(title),
        autoOpen: false,
        width: $(html).data('width'),
        height: $(html).data('height'),
        modal: true,
        buttons: buttons
      });
  };

  return cd;

})(cyberDojo || {}, jQuery);
