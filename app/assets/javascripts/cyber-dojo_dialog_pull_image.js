/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.dialog_pullImageThen = function(route, f) {
    var pullDialog = makePullDialog();
    var pullOverlay = $('<div id="pull-overlay"></div>');
    var pullSpinner = $('#pull-spinner');
    pullDialog.dialog('open');
    pullOverlay.insertAfter($('body'));
    pullSpinner.show();
    $.getJSON(route, cd.chosenLanguageAndTest(), function() {
      pullSpinner.hide();
      pullOverlay.remove();
      pullDialog.dialog('close');
      f();
    });
  };

  cd.chosenLanguageAndTest = function() {
    return {
      language: cd.chosenLanguage(),
          test: cd.chosenTest()
    };
  };

  cd.chosenLanguage = function() {
    return $('[id^=language_][class~=selected]').data('language');
  };

  cd.chosenTest = function() {
    return $('[id^=test_][class~=selected]').data('test');
  };

  var makePullDialog = function() {
    var html = '' +
      'This is the first time ' +
       '[' + cd.chosenLanguage() + ']+[' + cd.chosenTest() + '] ' +
       'has been chosen.<br/>' +
      "It's docker image is now being pulled onto the server.<br/>" +
      'This may take a minute or two.';
    return $('<div>')
      .html(html)
      .dialog({
        title: cd.dialogTitle('please wait ...'),
        closeOnEscape: true,
        close: function() { $(this).remove(); },
        autoOpen: false,
        width: 500,
        height: 200,
        modal: true,
      });
  };

  return cd;
})(cyberDojo || {}, jQuery);
