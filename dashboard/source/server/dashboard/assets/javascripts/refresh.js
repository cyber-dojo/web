'use strict';
$(() => {

  const cssId = 'traffic-lights';
  const $lights = $(`#${cssId}`);
  const $tHeadTr = $('table thead tr', $lights);
  const $tBody = $('table tbody', $lights);

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const sortState = {
    column: cd.urlParam('sort_by', 'name'), // 'name' or 'lights'
    direction: 'asc',                       // 'asc' or 'desc'
    toggle: (col) => {
      if (sortState.column === col) {
        sortState.direction = (sortState.direction === 'asc' ? 'desc' : 'asc');
      } else {
        sortState.column = col;
        sortState.direction = 'asc';
      }
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.refresh = () => {
    // A public cd.function so its callable from heartbeat() and
    // when auto-refresh/minute-columns checkboxes are clicked.
    const minuteColumns = cd.minuteColumns.isChecked() ? 'true' : 'false';
    const detailed = cd.detailed.isChecked() ? 'true' : 'false';
    const args = { 
      minute_columns:minuteColumns,
      detailed:detailed
    };
    const params = new URLSearchParams(args);
    fetch(cd.mountedPath(`/heartbeat/${cd.groupId()}?${params}`), { headers: cd.lib.jsonHeaders })
      .then(r => r.json())
      .then(data => {
        refreshTableHeadWith(data.time_ticks);
        refreshTableBodyWith(data.avatars);
        cd.pieChart($(`#${cssId} .pie`));
        document.querySelector('.scroll-handle').scrollIntoView({ behavior:'smooth', block:'nearest', inline:'nearest' });
      });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const refreshTableHeadWith = (timeTicks) => {
    $tHeadTr.empty();
    $tHeadTr.append($('<th>').append($sortHeaderDiv())); // always: matches fixed-column
    if (cd.minuteColumns.isChecked()) {
      Object.keys(timeTicks).forEach((minutes) => { // eg minutes == "1"
        const minute = timeTicks[minutes];          // eg minute == [ days,hours,minutes ]
        const $th = $('<th>');                      // or minute == { "collapsed":525 }
        unless(minute.collapsed, () => {
          ageTrafficLight(minute);
          $th.append($('<div>', { class:'time-tick' }));
          cd.createTip($th, cd.timeTick(minute));
        });
        $tHeadTr.append($th);
      });
      $tHeadTr.append($('<th>')); // to match scroll-handle
    }
    setAge();
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $sortHeaderDiv = () => {
    const arrow = (col) => {
      if (sortState.column !== col) { return ''; }
      return sortState.direction === 'asc' ? ' ▲' : ' ▼';
    };
    const activeClass = (col) => 'sort-widget' + (sortState.column === col ? ' sort-active' : '');

    const $name = $('<span>', { class: activeClass('name') })
      .text('Name' + arrow('name'))
      .click(() => { sortState.toggle('name'); cd.refresh(); });

    const $lightsCount = $('<span>', { class: activeClass('lights') })
      .text('Lights' + arrow('lights'))
      .click(() => { sortState.toggle('lights'); cd.refresh(); });

    return $('<div>', { class: 'sort-header' }).append($name).append($lightsCount);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  let dhmOldest = undefined;
  let dhmNewest = undefined;

  const ageTrafficLight = (dhm) => {
    const seconds = dhmSeconds(dhm);
    if (dhmOldest === undefined || seconds < dhmOldest) {
      dhmOldest = seconds;
    }
    if (dhmNewest === undefined || seconds > dhmNewest) {
      dhmNewest = seconds;
    }
  };

  const dhmSeconds = (dhm) => {
    const days=dhm[0],hours=dhm[1],minutes=dhm[2];
    return minutes*60 + hours*60*60 + days*24*60*60;
  };

  const dhmAge = () => {
    if (dhmOldest === undefined) { return dhm(0,0,0); }
    const seconds = dhmNewest - dhmOldest;
    const days    = (seconds / 60  / 60  / 24);
    const hours   = (seconds / 60  / 60) % 24;
    const minutes = (seconds / 60) % 60;
    return dhm(days,hours,minutes);
  };

  const dhm = (d,h,m) => {
    return {
         days:Math.floor(d),
        hours:Math.floor(h),
      minutes:Math.floor(m)
    };
  };

  const setAge = () => {
    const age = dhmAge();
    $('#days').text(age.days);
    $('#hours').text(age.hours);
    $('#minutes').text(age.minutes);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const unless = (truth, callBack) => {
    if (!truth) {
      callBack();
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const refreshTableBodyWith = (avatars) => {
    $tBody.empty();
    sortedAvatarKeys(avatars).forEach((groupIndex) => {
      const avatar = avatars[groupIndex];
      const kataId = avatar['kata_id'];
      const $tr = $('<tr>');
      const $fixedColumn = $('<div>', { class:'fixed-column' });
      $tBody.append($tr.append($('<th>').append($fixedColumn)));
      const args = appendAllLights($tr, kataId, groupIndex, avatar['lights']);
      $fixedColumn.append($avatarImage(kataId, groupIndex));
      $fixedColumn.append($trafficLightsPieChart(args.counts, kataId));
      $fixedColumn.append($trafficLightsCount(args));
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const sortedAvatarKeys = (avatars) => {
    const keys = Object.keys(avatars);
    const dir = sortState.direction === 'asc' ? 1 : -1;
    if (sortState.column === 'lights') {
      return keys.sort((a, b) => dir * (totalLightCount(avatars[a]) - totalLightCount(avatars[b])));
    }
    return keys.sort((a, b) => dir * (parseInt(a) - parseInt(b)));
  };

  const totalLightCount = (avatar) => {
    let total = 0;
    Object.values(avatar['lights']).forEach((lights) => {
      if (Array.isArray(lights)) {
        lights.forEach((light) => {
          if (isRAG(light.colour)) {
            total += 1;
          }
        });
      }
    });
    return total;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $avatarImage = (kataId, groupIndex) => {
    const $img = $('<img>', {
        src:`/images/avatars/${groupIndex}.jpg`,
      class:'avatar-image',
        alt:'avatar image'
    });
    $img.click(() => window.open(cd.reviewUrl(kataId, { index: -1 })));
    const apostrophe = '&#39;'
    cd.setupAvatarNameHoverTip($img, 'Review ', groupIndex, `${apostrophe}s<br/>current code`);
    return $img;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const appendAllLights = ($tr, kataId, groupIndex, minutes) => {
    // minutes = {
    //    "0": [ {...},{...},{...} ],
    //    "1": { "collapsed":525 },
    //  "526": [ {...},{...} ]
    // }
    const args = {
      'number':1,      // the UI traffic-light number
      'parity':'even', // for columns
      'counts':{}      // of each traffic-light colour
    };
    Object.keys(minutes).forEach((minute) => {
      const $td = $('<td>', { class:`${args.parity} column` });
      const $minuteBox = $('<div>', { class:'minute-box' });
      const lights = minutes[minute];
      appendOneMinutesLights($minuteBox, kataId, groupIndex, lights, args);
      $td.append($minuteBox);
      $tr.append($td);
    });
    $tr.append($('<td>', { class:'scroll-handle' }));
    return args;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const appendOneMinutesLights = ($minuteBox, kataId, groupIndex, lights, args) => {
    if (lights.collapsed) {       // eg lights === { "collapsed":525 }
      $minuteBox.append($('<span>', { class:'collapsed-columns' }));
    } else {                      // eg lights === [ {"index":3,"colour":"red"},{...} ]
      lights.forEach((light) => { // eg light === {"index":3,"colour":"red"}
        if (cd.lib.hasPrediction(light)) {
          $minuteBox.append($predictImage(light));
        }
        const colour = light.colour;
        let $light;
        if (cd.lib.isRevert(light)) {
          $light = $revertImage(colour);
        }
        else if (cd.lib.isCheckout(light)) {
          $light = $checkoutImage(colour);
        }
        else if (isFileEvent(colour)) {
          $light = $fileEventImage(light);
        }
        else {
          $light = $ragImage(colour);
        }
        $minuteBox.append($light);
        setupHandlers($light, light, groupIndex, kataId);

        unless(args.counts[colour], () => args.counts[colour] = 0);
        if (isRAG(colour)) {
          args.counts[colour] += 1;
          args.lastColour = colour; // (for colour of traffic-lights-count)
        }
      });
    }
    args.parity = (args.parity === 'odd' ? 'even' : 'odd');
  };

  const isRAG = (colour) => {
    return colour.startsWith('red') || colour.startsWith('amber') || colour.startsWith('green');
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const setupHandlers = ($light, light, groupIndex, kataId) => {
    $light.click(() => window.open(cd.reviewUrl(kataId, light)));
    cd.setupTrafficLightTip($light, kataId, groupIndex, light);
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.reviewUrl = (kataId, light) => {
    const diff = cd.detailed.isChecked() ? '&diff=detailed' : '';
    return `/review/show/${kataId}?now_index=${light.index}${diff}`;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $predictImage = (light) => {
    const correct = (light.predicted === light.colour);
    const icon = correct ? 'tick' : 'cross';
    return $('<img>', {
      class: `${icon} ${light.predicted}`,
        src: `/images/traffic-light/circle-${icon}.png`
    });
  };

  const $revertImage = (colour) => {
    return $('<img>', {
      class: `diff-traffic-light revert ${colour}`,
        src: '/images/traffic-light/circle-revert.png'
    });
  };

  const $checkoutImage = (colour) => {
    return $('<img>', {
      class: `diff-traffic-light checkout ${colour}`,
        src: '/images/traffic-light/circle-checkout.png'
    });
  };

  const $ragImage = (colour) => {
    return $('<img>', {
        src: `/images/traffic-light/${colour}.png`,
      class: 'diff-traffic-light',
        alt: `${colour} traffic-light`
    });
  };

  const isFileEvent = (colour) => colour.startsWith('file_');

  const $fileEventImage = (light) => {
    const icon = cd.lib.isTestFile(light.filename) ? 'file_test' : 'file_code';
    return $('<img>', {
        src: `/images/traffic-light/${icon}.png`,
      class: 'diff-traffic-light',
        alt: `${light.colour} traffic-light`
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $trafficLightsPieChart = (counts, kataId) => {
    return '' +
      `<div
         class="pie-chart-wrapper">
         <canvas
           class="pie"
           data-red-count="${counts.red || 0}"
           data-amber-count="${counts.amber || 0}"
           data-green-count="${counts.green || 0}"
           data-timed-out-count="${counts.timedOut || 0}"
           data-key="${kataId}"
           width="20"
           height="20">
         </canvas>
       </div>`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $trafficLightsCount = (args) => {
    let total = 0;
    Object.keys(args.counts).forEach((key) => {
      total += args.counts[key];
    });
    const $count = $('<div>', {
      class:`traffic-light-count ${args.lastColour}`
    }).text(total);
    cd.setupTrafficLightCountHoverTip($count, args.counts);
    return $count;
  };

});
