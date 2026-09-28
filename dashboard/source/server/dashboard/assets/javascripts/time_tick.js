'use strict';
(() => {

  const d = "<span class='d-for-days'>d</span>";
  const h = "<span class='h-for-hours'>h</span>";
  const m = "<span class='m-for-minutes'>m</span>";

  cd.timeTick = (dhm) => {
    const days = dhm[0];
    const hours = dhm[1];
    const minutes = dhm[2];
    let tick = '';
    if (days > 0) {
      tick += days + d + '&thinsp;';
    }
    if (hours > 0) {
      tick += hours + h + '&thinsp;';
    }
    tick += minutes + m;
    return tick;
  };

})();
