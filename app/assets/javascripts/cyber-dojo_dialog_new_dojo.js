/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.newDojoDialog = function(params) {
    const id = params['id'];
    const html = '' +
      "<div id='title'>" +
        'forked session ID is' +
      '<div>' +
      '<div>' +
        "<span id='dojo-id'>" +
          id.substring(0,6) +
        '</span>' +
      '</div>';

    $('<div id="forked-dojo">')
      .html(html)
      .dialog({
        title: '',
        autoOpen: true,
        modal: true,
        width: 425,
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
