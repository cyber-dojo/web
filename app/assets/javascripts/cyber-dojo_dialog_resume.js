/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.resume = function(id, avatarName) {
    const url = '/kata/edit/' + id + '?avatar=' + avatarName;
    window.location.href = cd.homePageUrl(id);
    window.open(url);
  };

  return cd;

})(cyberDojo || {}, jQuery);
