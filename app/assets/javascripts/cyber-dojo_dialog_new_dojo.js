/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.newDojoDialog = function(params, from) {
    cd.dialog_pullImageIfNeededThen(params, from, showNewDojoDialog);
  };

  var showNewDojoDialog = function(params, from) {
    var id = params['id'];
    var gotoPage = function(url) {
      if (from == 'from_setup') {
        window.location = url; // same tab
      }
      if (from == 'from_fork') {
        window.open(url); // new tab
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
        title: cd.dialogTitle('setup&nbsp;a&nbsp;new&nbsp;practice&nbsp;session'),
        autoOpen: true,
        modal: true,
        width: 435,
        closeOnEscape: true,
        open: function() {
          var pane = $('.ui-dialog-buttonpane');
          pane.find('button:contains("goto home page")').addClass('new-dojo-dialog-button enter-page');
          pane.find('button:contains("start programming")').addClass('new-dojo-dialog-button start-coding');
        },
        close: function() {
          $(this).remove();
        },
        buttons: {
          'goto home page': function() {
            gotoPage('/dojo/index/' + id);
            $(this).remove();
          },
          'start programming': function() {
            cd.startAnimal(id, from);
            $(this).remove();
          }
        }
      });
  };

  return cd;

})(cyberDojo || {}, jQuery);
