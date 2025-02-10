/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  let avatarNamesCache = undefined;

  cd.lib.avatarName = (n) => {
    if (avatarNamesCache === undefined) {
      $.ajax({
              type: 'GET',
               url: '/images/avatars/names.json',
          dataType: 'json',
             async: false,
           success: (avatarsNames) => {
             avatarNamesCache = avatarsNames;
           }
      });
    }
    return avatarNamesCache[n];
  };

  return cd;

})(cyberDojo || {}, jQuery);
