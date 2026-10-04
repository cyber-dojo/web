// Wrapped so nothing but its one global leaks into the scope the apps'
// concatenated asset bundles share.
(() => {
'use strict';

// Returns a new <dialog> element, not yet shown (call .showModal() on it),
// with a header holding title and a close button, and html below. html may
// carry a data-width (in px) to fix the dialog's width. The dialog removes
// itself from the page when it closes. Used by every app that pops up a
// dialog (web's app-bar dialogs, creator's group-is-full dialog).
window.cdDialog = (html, title) => {
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
})();
