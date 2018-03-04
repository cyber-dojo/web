/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.hexOnly = function(element) {
    // Only accept hex input.
    // Also accepts a Ctrl-V paste event which will allow
    // non-hex chars to be entered.
    element.keypress(function(e) {
      var str = String.fromCharCode(!e.charCode ? e.which : e.charCode);
      if (e.which == 0 || e.charCode == 0) { // special key
        return true;
      }
      else if (str.match(/[a-fA-F0-9]/)) { // hex key
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
