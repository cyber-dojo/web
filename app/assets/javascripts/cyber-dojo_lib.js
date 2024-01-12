/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.urlParam = (name, fallBack) => {
    const params = new URLSearchParams(window.location.search);
    return params.get(name) || fallBack;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -

  cd.lib.isVisible = (event) => {
    // Used by both app/views/kata and app/view/review
    // Eg don't show event[0] == creation
    switch (event.colour) {
    case 'create':
    case 'red':
    case 'amber':
    case 'green':
    case 'pulling':
    case 'timed_out':
    case 'faulty':
      return true;
    default:
      return false;
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.$makeAvatarImage = (avatarIndex) => {
    const $img = $('<img>', {
      class:'avatar-image',
        src:`/images/avatars/${avatarIndex}.jpg`,
        alt:`avatar number ${avatarIndex}`
    });
    cd.createTip($img, cd.lib.avatarName(avatarIndex));
    return $img;
  };

  return cd;

})(cyberDojo || {}, jQuery);
