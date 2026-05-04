/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.dialogTitle = (title) => {
    return `<span class="large dialog title">${title}<span>`;
  };

  cd.dialog = function(html, title, close) {
    const dialog = document.createElement('dialog');
    const width = $(html).data('width');
    if (width) { dialog.style.width = width + 'px'; }
    $(dialog).html(`
      <header>
        <span class="dialog-title">${title}</span>
        <button type="button" class="dialog-close">close</button>
      </header>
      <div class="info"></div>
    `);
    $('.info', dialog).append(html);
    $('body').append(dialog);
    $(dialog).on('close', () => dialog.remove());
    $('.dialog-close', dialog).click(() => dialog.close());
    return dialog;
  };

  return cd;

})(cyberDojo || {}, jQuery);
