/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.htmlEscape = (str) => {
    const div = document.createElement('div');
    const text = document.createTextNode(str);
    div.appendChild(text);
    return div.innerHTML;
  };

  return cd;

})(cyberDojo || {}, jQuery);
