/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.urlParam = (name, fallBack) => {
    const params = new URLSearchParams(window.location.search);
    return params.get(name) || fallBack;
  };

  cd.lib.getEvents = (id, callback) => {
    const params = new URLSearchParams({id: id});
    return fetch(`/saver/kata_events?${params}`, { headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' } })
      .then(r => r.json())
      .then(json => callback(json['kata_events']));
  };

  // Event 0 is the kata's creation: it carries the starting files but no
  // traffic-light, has no predecessor, and is the one event every kata has
  // whether or not anyone has run a test. Callers ask through here rather than
  // spelling index==0, or length==1, themselves. Relies on an event's index
  // being its position in the events array, which the saver guarantees by
  // placing each write at head+1 (saver kata_v2.rb commit_on_main).
  cd.lib.isCreationEvent = (event) => {
    return event.index == 0;
  };

  // True when any of a kata's events is something the creator did, ie the kata
  // is more than a bare join. The avatar-navigator and dashboard both call an
  // avatar with no such event inactive.
  cd.lib.hasActivity = (events) => {
    return events.some((event) => !cd.lib.isCreationEvent(event));
  };

  cd.lib.isLight = (event) => {
    return !cd.lib.isFileEvent(event);
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

  cd.lib.dottedIndex = (light) => {
    if (light.minor_index == 0) {
      return `${light.major_index}`;
    } 
    else {
      return `${light.major_index}.${light.minor_index}`;
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
