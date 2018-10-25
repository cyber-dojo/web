/*global jQuery,cyberDojo*/

var cyberDojo = ((cd, $) => {
  'use strict';

  cd.showReviewUrl = (id, _avatarName, wasTag, nowTag, filename) => {
    return '/review/show/' + id +
      '?was_tag=' + wasTag +
      '&now_tag=' + nowTag +
      '&filename=' + filename;
  };

  return cd;

})(cyberDojo || {}, jQuery);
