/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  // Returns a new, not yet shown, <dialog>; see common/javascripts/dialog.js.
  cd.dialog = (html, title) => cdDialog(html, title);

  return cd;

})(cyberDojo || {}, jQuery);
