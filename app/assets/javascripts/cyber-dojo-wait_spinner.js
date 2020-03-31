/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  const waitSpinner = $('<div>', {
    id:'wait-overlay',
    style:'display:none;'
  }).add($('<img>', {
    src:'/images/rotate-cyber-dojo.gif',
     id:'wait-spinner'
  }));

  cd.showWaitSpinner = (onComplete) => {
    waitSpinner
      .insertAfter($('body'))
      .fadeIn('slow', onComplete);
  };

  cd.hideWaitSpinner = (onComplete) => {
    waitSpinner
      .fadeOut('fast', () => {
        waitSpinner.remove();
        onComplete();
      });
  };

  return cd;

})(cyberDojo || {}, jQuery);
