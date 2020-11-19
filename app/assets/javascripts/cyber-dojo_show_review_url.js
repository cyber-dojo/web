/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.showReviewUrl = (kataId, wasIndex, nowIndex) => {
    return `/review/show/${kataId}` +
      `?was_index=${wasIndex}` +
      `&now_index=${nowIndex}`;
  };

  return cd;

})(cyberDojo || {}, jQuery);
