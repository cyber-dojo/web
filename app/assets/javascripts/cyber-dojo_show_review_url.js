/*global jQuery,cyberDojo*/

var cyberDojo = ((cd, $) => {
  'use strict';

  cd.showReviewUrl = (id, avatarName, wasTag, nowTag, filename) => {
    return '/review/show/' + id +
      '?avatar=' + avatarName +
      '&was_tag=' + wasTag +
      '&now_tag=' + nowTag +
      '&filename=' + filename;
  };

  return cd;

})(cyberDojo || {}, jQuery);
