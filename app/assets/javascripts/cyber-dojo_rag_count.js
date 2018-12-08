/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.ragCount = (lights, colour) => {
    let count = 0;
    lights.each((_, node) => {
      if ($(node).data('colour') == colour  ) {
        count += 1;
      }
    });
    return count;
  };

  return cd;

})(cyberDojo || {}, jQuery);
