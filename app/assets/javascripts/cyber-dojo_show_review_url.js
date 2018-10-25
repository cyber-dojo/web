/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.showReviewUrl = (id, wasTag, nowTag, filename) => {
    return '/review/show/' + id +
      '?was_tag=' + wasTag +
      '&now_tag=' + nowTag +
      '&filename=' + filename;
  };

  return cd;

})(cyberDojo || {}, jQuery);
