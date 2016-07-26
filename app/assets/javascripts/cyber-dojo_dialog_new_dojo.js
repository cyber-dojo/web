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

    var html = '' +
      "<div class='align-center'>" +
        "<div class='avatar-background'>" +
          "<span class='dojo-id'>" +
            id.substring(0,6) +
          '</span>' +
        '</div>' +
      '</div>';

    $('<div>')
      .html(html)
      .dialog({
        title: cd.dialogTitle('new&nbsp;practice&nbsp;session&nbsp;set&nbsp;up'),
        autoOpen: true,
        modal: true,
        width: 435,
        closeOnEscape: true,
        open: function() {
          var pane = $('.ui-dialog-buttonpane');
          pane.find('button:contains("goto home page")').addClass('new-dojo-dialog-button home-page');
          pane.find('button:contains("goto enter page")').addClass('new-dojo-dialog-button enter-page');
          pane.find('button:contains("start coding")').addClass('new-dojo-dialog-button start-coding');
        },
        close: function() {
          $(this).remove();
        },
        buttons: {
          'goto home page': function() {
            gotoPage(cd.homePageUrl(id));
            $(this).remove();
          },
          'goto enter page': function() {
            gotoPage('/enter/show/' + id);
            $(this).remove();
          },
          'start coding': function() {
            cd.startAnimal(id, from);
            $(this).remove();
          }
        }
      });
  };

  return cd;

})(cyberDojo || {}, jQuery);
