/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  const overlaySpinner = $('<div>', {
     id:'wait-overlay'
  }).add($('<img>', {
     id:'wait-spinner',
    src:'/images/rotate-cyber-dojo.gif'
  }));

  cd.showWaitSpinner = () => {
    overlaySpinner.insertAfter($('body'));
  };

  cd.hideWaitSpinner = () => {
    overlaySpinner.remove();
  };

  return cd;

})(cyberDojo || {}, jQuery);
