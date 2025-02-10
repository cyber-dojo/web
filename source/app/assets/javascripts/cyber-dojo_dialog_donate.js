/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.dialog_donate = () => {
    const title = 'please donate';
    const donateButton = () => {
      return '' +
      '<form action="https://www.paypal.com/cgi-bin/webscr"' +
           ' method="post"' +
           ' id="donate-form"' +
           ' target="_blank">' +
      '<input type="hidden"' +
            ' name="cmd"' +
            ' value="_s-xclick">' +
      '<input type="hidden"' +
            ' name="hosted_button_id"' +
            ' value="7HAUYJCMFCS8C">' +
      '<input type="image"' +
            ' src="/images/donate.png"' +
            ' width="79"' +
            ' height="22"' +
            ' name="submit"' +
            ' alt="PayPal - The safe, easier way to pay online.">' +
      '<img alt=""' +
          ' src="https://www.paypalobjects.com/en_GB/i/scr/pixel.gif"' +
          ' width="1"' +
          ' height="1">' +
      '</form>';
    };

    const html = '' +
      '<div>' +
        '<div class="info">' +
          '<table>' +
            '<tr>' +
              '<td>' + donateButton() + '</td>' +
              '<td>' +
                "for an individual, we suggest donating $10+" +
              '</td>' +
            '</tr>' +
            '<tr>' +
              '<td>' + donateButton() + '</td>' +
              '<td>' +
                "for a non-profit meetup, we suggest donating $25+" +
              '</td>' +
            '</tr>' +
            '<tr>' +
              '<td>' + donateButton() + '</td>' +
              '<td>' +
                "for a commercial organization, we suggest donating $1000+" +
              '</td>' +
            '</tr>' +
           '</table>' +
        '</div>' +
        'if you need an invoice, please email <em>license@cyber-dojo.org</em>' +
      '</div>';

    const div = $(html).dialog({
                width: 650,
             autoOpen: true,
        closeOnEscape: true,
                modal: true,
                title: cd.dialogTitle('please donate'),
          beforeClose: event => {
            if (event.keyCode === $.ui.keyCode.ESCAPE) {
              div.remove();
              return true;
            }
          }
    });

  };

  return cd;

})(cyberDojo || {}, jQuery);
