/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.invoiceMe = () => {
    const url = "mailto:pies@cyber-dojo.org?subject=cyber-dojo donation - please invoice me";
    window.open(url, '_blank');
    return false;
  };

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
      '<div data-width="600">' +
        '<table>' +
          '<tr>' +
            '<td>' + donateButton() + '</td>' +
            '<td>' +
              "&nbsp;&nbsp;for an individual, we suggest donating $5+" +
            '</td>' +
          '</tr>' +
          '<tr>' +
            '<td>' + donateButton() + '</td>' +
            '<td>' +
              "&nbsp;&nbsp;for a non-profit meetup, we suggest donating $15+" +
            '</td>' +
          '</tr>' +
          '<tr>' +
            '<td>' + donateButton() + '</td>' +
            '<td>' +
              "&nbsp;&nbsp;for a commercial organization, we suggest donating $500+" +
            '</td>' +
          '</tr>' +
          '<tr>' +
            '<td colspan="2">' +
              'if you need an invoice, please ' +
              '<button id="email-me" onclick="return cd.invoiceMe();">email</button>' +
            '</td>' +
          '</tr>' +
         '</table>' +
      '<div>';

    return cd.dialog(html, title, 'close');
  };

  return cd;

})(cyberDojo || {}, jQuery);
