/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.onlyBase58 = (element) => {
    // Only accept base58 input.
    // Also accepts a Ctrl-V paste event which
    // will allow any chars to be entered.
    element.keypress((e) => {
      const str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
      if (e.which == 0 || e.charCode == 0) { // special key
        return true;
      }
      else if (str.match(/IOio/)) {
        return false
      }
      else if (str.match(/[a-zA-Z0-9]/)) {
        return true;
      }
      else {
        e.preventDefault();
        return false;
      }
    });
  };

  return cd;

})(cyberDojo || {}, jQuery);
