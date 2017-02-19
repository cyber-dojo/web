/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.timer = {
    startTime: Date.now().valueOf(),
    totalTime: 1000 * 60 * 5,
    timerID: null
  };

  cd.timer.elapsedDialog = function() {
    var html = '';
    html += '<div>';
    html += 'Time to change the driver';
    html += '</div>';

    var node = $(html);
    node.dialog({
      autoOpen: true,
      modal: true,
      title: cd.dialogTitle('Driver timer'),
      buttons: { restart: function() {
        cd.timer.restart();
        $(this).remove();
      } },
      closeOnEscape: false,
      width: '350'
    });
  };

  cd.timer.handler = function() {
    var tdiff = Date.now().valueOf() - cd.timer.startTime;
    var percent;

    if(tdiff < cd.timer.totalTime) {
      percent = (tdiff * 100) / cd.timer.totalTime;
    } else {
      cd.timer.stopTimerIfRunning();
      percent = 100;
      cd.timer.elapsedDialog();
    }

    $("#driverTimerProgress").css('width', percent + '%');
  };

  cd.timer.stopTimerIfRunning = function() {
    if(cd.timer.timerID != null) {
      clearInterval(cd.timer.timerID);
      cd.timer.timerID = null;
    }
  };

  cd.timer.restart = function() {
    cd.timer.stopTimerIfRunning();
    var containter = $("#driverTimerContainer");
    containter.css('bottom', $("#footer").outerHeight(true) + 'px');
    containter.show();
    cd.timer.startTime = Date.now().valueOf();
    cd.timer.timerID = setInterval(cd.timer.handler, 200);
    cd.timer.handler();
  };

  cd.timer.start = function(minutes) {
    cd.timer.stopTimerIfRunning();
    cd.timer.totalTime = 1000 * 60 * minutes;
    cd.timer.restart();
  };

  cd.timer.stop = function() {
    cd.timer.stopTimerIfRunning();
    $("#driverTimerContainer").hide();
  };

  return cd;

})(cyberDojo || {}, jQuery);
