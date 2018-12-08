/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.dialogError = (info) => {
    const html = $('<textarea>', {
      'data-width':620,
              'id':'error',
        'readonly':'readonly'
    }).val(info);
    cd.dialog(html, 'error', 'close').dialog('open');
  };

  return cd;

})(cyberDojo || {}, jQuery);
