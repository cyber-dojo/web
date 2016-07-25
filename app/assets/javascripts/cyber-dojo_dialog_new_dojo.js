/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";


  cd.newDojoDialog = function(id, from) {

    var gotoPage = function(url) {
      if (from == 'from_setup') {
        window.location = url;
      }
      if (from == 'from_fork') {
        window.open(url);
      }
    };

    var removeDialog = function(dialog) {
      if (from == 'from_setup') {
        dialog.remove();
      }
    };

    var html = '' +
      "<div class='align-center'>" +
        "<div style='font-size:1.0em;'>" +
          "it's id is" +
        '</div>' +
        "<div class='avatar-background'>" +
          "<span class='centerer'></span>" +
          "<span class='dojo-id'>" +
            id.substring(0,6) +
          '</span>' +
        '</div>' +
      '</div>';

    $('<div>')
      .html(html)
      .dialog({
        title: cd.dialogTitle('new&nbsp;practice&nbsp;session&nbsp;created'),
        autoOpen: true,
        modal: true,
        width: 435,
        closeOnEscape: true,
        close: function() {
          $(this).remove();
        },
        buttons: {
          'goto home page': function() {
            gotoPage(cd.homePageUrl(id));
            removeDialog($(this));
          },
          'goto enter page': function() {
            gotoPage('/enter/show/' + id);
            removeDialog($(this));
          },
          'start coding': function() {
            cd.startAnimal(id, from);
            removeDialog($(this));
          },
          'close': function() {
            $(this).remove();
          }
        }
      });
  };

  return cd;

})(cyberDojo || {}, jQuery);
