/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.showReviewUrl = (id, wasIndex, nowIndex, filename) => {
    return `/review/show/${id}` +
      `?was_index=${wasIndex}` +
      `&now_index=${nowIndex}` +
      `&filename=${filename}`;
  };

  return cd;

})(cyberDojo || {}, jQuery);
