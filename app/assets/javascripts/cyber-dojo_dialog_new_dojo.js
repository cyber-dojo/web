/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.newDojoDialog = function(params) {
    const id = params['id'];
    const phonetic = params['phonetic']
    const html = '' +
      "<div id='title'>" +
        'forked session ID is' +
      '<div>' +
      '<div>' +
        "<span id='dojo-id'>" +
          id.substring(0,6) +
        '</span>' +
      '</div>' +
      '<div>' +
        "<span id='phonetic-dojo-id'>" +
          phonetic +
        '</span>' +
      '</div>';

    $('<div id="forked-dojo">')
      .html(html)
      .dialog({
        title: '',
        autoOpen: true,
        modal: true,
        width: 600,
        closeOnEscape: true,
        buttons: {
          'close': function() {
            $(this).remove();
          }
        }
      });
  };

  return cd;

})(cyberDojo || {}, jQuery);
