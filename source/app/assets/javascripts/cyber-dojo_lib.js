/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.urlParam = (name, fallBack) => {
    const params = new URLSearchParams(window.location.search);
    return params.get(name) || fallBack;
  };

  cd.lib.getEvents = (id, callback) => {
    const name = 'kata_events';
    $.getJSON(`/saver/${name}`, {id: id}, (json) => {
      const events = json[name];
      callback(events);
    });
  };

  cd.lib.isLight = (event) => {
    switch (event.colour) {
    case 'create':
    case 'red':
    case 'red_special':
    case 'amber':
    case 'amber_special':
    case 'green':
    case 'green_special':
      return true;
    default:
      return false;
    }
  };

  cd.lib.isFileEvent = (event) => {
    switch (event.colour) {
    case 'file_create':
    case 'file_delete':
    case 'file_rename':
    case 'file_edit':
      return true;
    default:
      return false;
    }
  };

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
