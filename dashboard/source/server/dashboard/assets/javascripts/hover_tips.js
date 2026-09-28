'use strict';
(() => {

  cd.setupAvatarNameHoverTip = ($avatar, prefix, avatarIndex, suffix) => {
    setTip($avatar, () => {
      const avatarName = cd.lib.avatarName(avatarIndex);
      const tip = `${prefix}${avatarName}${suffix}`;
      showHoverTip($avatar, tip);
    });
  };

  // - - - - - - - - - - - - - - - - - - - -
  cd.setupTrafficLightTip = ($light, kataId, avatarIndex, light) => {
    setTip($light, () => {
      const args = { id:kataId, was_index:light.previous_index, now_index:light.index };
      const params = new URLSearchParams(args);
      fetch(cd.mountedPath(`/diff_summary?${params}`), { headers: cd.lib.jsonHeaders })
        .then(r => r.json())
        .then(json => {
          const diffSummary = json.diff_summary;
          const $tip = $(document.createDocumentFragment());
          $tip.append($trafficLightSummary(kataId, avatarIndex, light));
          $tip.append($diffLinesTable(diffSummary));
          cd.showHoverTip($light, $tip);
        });
    });
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $trafficLightSummary = (kataId, avatarIndex, light) => {
    const $table = $('<table>');
    const $tr = $('<tr>');
    $tr.append($avatarImageTd(avatarIndex));
    $tr.append($trafficLightCountTd(light));
    $tr.append($trafficLightMiniTextTd(kataId, light));
    $table.append($tr);
    if (light.time) {
      const $dtTr = $('<tr>');
      const $dtTd = $('<td>', { colspan: 4, class: 'datetime' });
      $dtTd.text(formatDateTime(light.time));
      $dtTr.append($dtTd);
      $table.append($dtTr);
    }
    return $table;
  };

  const formatDateTime = (timeA) => {
    const pad = (n) => String(n).padStart(2, '0');
    const [year, month, day, hour, minute, second] = timeA;
    return `${year}:${pad(month)}:${pad(day)} ${pad(hour)}:${pad(minute)}:${pad(second)}`;
  };

  const $trafficLightMiniTextTd = (kataId, light) => {
    return $('<td class="mini-text">').html(miniTextInfo(kataId, light));
  };

  const miniTextInfo = (kataId, light) => {
    if (light.index == 0) {
      return 'Kata created';
    }
    else if (light.colour === 'pulling') {
      return 'Image being prepared';
    }
    else if (light.colour === 'timed_out') {
      return 'Timed out';
    }
    else if (light.colour === 'faulty') {
      return `Fault! not ${cssColour('red')}, ${cssColour('amber')}, or ${cssColour('green')}`;
    }
    else if (cd.lib.hasPrediction(light)) {
      return trafficLightPredictInfo(light);
    }
    else if (cd.lib.isRevert(light)) {
      return trafficLightRevertInfo(light);
    }
    else if (cd.lib.isCheckout(light)) {
      return trafficLightCheckoutInfo(kataId, light);
    }
    else if (light.colour == 'file_create') {
      return 'Review created file';
    }
    else if (light.colour == 'file_delete') {
      return 'Review deleted file';
    }
    else if (light.colour == 'file_rename') {
      return 'Review renamed file';
    }
    else if (light.colour == 'file_edit') {
      return 'Review edited file';
    }
    else {
      const colour = cssColour(light.colour);
      return `Review ${colour}`;
    }
  };

  const trafficLightPredictInfo = (light) => {
    const colour = light.colour
    const predicted = light.predicted;
    return `Predicted ${cssColour(predicted)}, got ${cssColour(colour)}`;
  };

  const trafficLightRevertInfo = (light) => {
    const colour = cssColour(light.colour);
    const index = cssColour(light.colour, light.index - 2)
    return `Auto-reverted to ${colour} ${index}`;
  };

  const trafficLightCheckoutInfo = (kataId, light) => {
    const colour = cssColour(light.colour);
    const index = cssColour(light.colour, light.checkout.index);
    if (kataId === light.checkout.id) {
      return `Reverted to ${colour} ${index}`;
    } else {
      const name = cd.lib.avatarName(light.checkout.avatarIndex);
      return `Checked-out ${name}'s ${colour} ${index}`;
    }
  };

  const cssColour = (colour, text = colour) => {
    return `<span class="${colour}">${text}</span>`;
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $avatarImageTd = (avatarIndex) => {
    const $td = $('<td>');
    if (avatarIndex != '') {
      const $img = $('<img>', {
          src: `/images/avatars/${avatarIndex}.jpg`,
        class: 'traffic-light-diff-tip-avatar-image'
      });
      $td.append($img);
    }
    return $td;
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $trafficLightCountTd = (event) => {
    const colour = event.colour;
    const index = (event.minor_index == 0)
      ? `${event.major_index}`
      : `${event.major_index}.${event.minor_index}`;
    const $count = $('<span>', {
      class:`traffic-light-count ${colour}`
    }).text(index);
    return $('<td>').append($count);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $diffLinesTable = (diffs) => {
    let count = 0;
    const $table = $('<table>', { class:'filenames' });
    const filenames = diffs.map(diff => diffFilename(diff));
    sortedFilenames(filenames).forEach(filename => {
      const fileDiff = diffs.find(diff => diffFilename(diff) === filename);
      const addedCount = fileDiff.line_counts['added'];
      const deletedCount = fileDiff.line_counts['deleted'];
      if (fileDiff.type != 'unchanged') {
        count += 1;
        const $tr = $('<tr>');
        $tr.append($lineCountTd('deleted', fileDiff));
        $tr.append($lineCountTd('added', fileDiff));
        $tr.append($diffFilenameTd(fileDiff));
        $table.append($tr);
      }      
    });
    if (count == 0) {
      return '';
    }
    else {    
      return $table;
    }
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $lineCountTd = (type, file) => {
    const lineCount = file.line_counts[type];
    const $count = $('<div>', { class:`diff-line-count ${type}` });
    $count.html(lineCount);
    return $('<td>').append($count);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $diffFilenameTd = (diff) => {
    const filename = diffFilename(diff);
    const testClass = cd.lib.isTestFile(filename) ? 'test-file' : 'non-test-file';
    const $filename = $('<div>', { class: `diff-filename ${diff.type} ${testClass}` });
    $filename.text(filename);
    return $('<td>').append($filename);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const diffFilename = (diff) => {
    if (diff.type === 'deleted') {
      return diff.old_filename;
    } else {
      return diff.new_filename;
    }
  };

  // - - - - - - - - - - - - - - - - - - - -
  const sortedFilenames = (filenames) => {
    const sliced = filenames.slice();
    sliced.sort(orderer);
    return sliced;
  };

  const orderer = (lhs, rhs) => {
    const lhsFileCat = fileCategory(lhs);
    const rhsFileCat = fileCategory(rhs);
    if (lhsFileCat < rhsFileCat)      { return -1; }
    else if (lhsFileCat > rhsFileCat) { return +1; }
    else if (lhs < rhs)               { return -1; }
    else if (lhs > rhs)               { return +1; }
    else                              { return  0; }
  };

  const fileCategory = (filename) => {
    let category = undefined;
    if (isHighlight(filename))    { category = 1; }
    else if (isSource(filename))  { category = 2; }
    else                          { category = 3; }
    // Special cases
    if (filename === 'readme.txt')    { category = 0; } // [A]
    if (filename === 'cyber-dojo.sh') { category = 3; } // [B]
    return category;
    // [A] Always at the top
    // [B] Shell test frameworks (eg shunit2) use .sh extension
    //     but cyber-dojo.sh is not a user source file.
  };

  const isHighlight = (filename) => {
    // cd.highlightFilenames() is in views/manifest.erb
    return cd.highlightFilenames().includes(filename);
  };

  const isSource = (filename) => {
    // cd.extensionFilenames() is in views/manifest.erb
    return cd.extensionFilenames().find(ext => filename.endsWith(ext));
  };

  // - - - - - - - - - - - - - - - - - - - -
  cd.setupTrafficLightCountHoverTip = ($count, counts) => {
    const reds = counts.red || 0;
    const ambers = counts.amber || 0;
    const greens = counts.green || 0;
    const timeOuts = counts.timed_out || 0;

    const tr = (s) => `<tr>${s}</tr>`;
    const td = (s) => `<td>${s}</td>`;
    const trLight = (colour, count) => {
      return tr(td('<img' +
                   " class='traffic-light-diff-tip-traffic-light-image'" +
                   ` src='/images/traffic-light/${colour}.png'>`) +
                td(`<div class='traffic-light-diff-tip-tag ${colour}'>` +
                   count +
                   '</div>'));
    };
    let html = '';
    html += '<table>';
    html += trLight('red', reds);
    html += trLight('amber', ambers);
    html += trLight('green', greens);
    if (timeOuts > 0) {
      html += trLight('timed_out', timeOuts);
    }
    html += '</table>';

    cd.createTip($count, html);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const nativePosition = (tipEl, myStr, atStr, $anchor) => {
    const anchor = $anchor[0].getBoundingClientRect();
    const tip    = tipEl.getBoundingClientRect();
    const sx = window.scrollX;
    const sy = window.scrollY;
    const vw = window.innerWidth;
    const vh = window.innerHeight;

    const parseSide = (str) => {
      let h = 'center', v = 'center', vOff = 0;
      str.trim().split(/\s+/).forEach(word => {
        const m = word.match(/^(left|right|top|bottom)([+-]\d+)?$/);
        if (!m) return;
        const base = m[1], off = m[2] ? parseInt(m[2], 10) : 0;
        if (base === 'left' || base === 'right') { h = base; }
        else { v = base; vOff = off; }
      });
      return { h, v, vOff };
    };

    const at = parseSide(atStr);
    const my = parseSide(myStr);

    const atX = at.h === 'left'  ? anchor.left  + sx
              : at.h === 'right' ? anchor.right  + sx
              : anchor.left + anchor.width / 2 + sx;
    const atY = at.v === 'top'    ? anchor.top    + sy + at.vOff
              : at.v === 'bottom' ? anchor.bottom + sy + at.vOff
              : anchor.top + anchor.height / 2 + sy + at.vOff;

    const myX = my.h === 'left'  ? 0
              : my.h === 'right' ? tip.width
              : tip.width / 2;
    const myY = my.v === 'top'    ? my.vOff
              : my.v === 'bottom' ? tip.height + my.vOff
              : tip.height / 2 + my.vOff;

    let left = atX - myX;
    let top  = atY - myY;

    if (left + tip.width  > sx + vw) { left = anchor.left + sx - tip.width; }
    if (left < sx)                   { left = sx; }
    if (top  + tip.height > sy + vh) { top  = anchor.top  + sy - tip.height; }
    if (top  < sy)                   { top  = sy; }

    tipEl.style.left = left + 'px';
    tipEl.style.top  = top  + 'px';
  };

  // - - - - - - - - - - - - - - - - - - - -
  cd.showHoverTip = (node, tip, where) => {
    if (where === undefined) { where = {}; }
    if (where.my === undefined) { where.my = 'top'; }
    if (where.at === undefined) { where.at = 'bottom'; }
    if (where.of === undefined) { where.of = node; }

    if (!node.attr('disabled')) {
      if (!node.hasClass('mouse-has-left')) {
        const hoverTip = $('<div>', { 'class': 'hover-tip' }).html(tip);
        hoverTipContainer().html(hoverTip);
        nativePosition(hoverTip[0], where.my, where.at, where.of);
      }
    }
  };

  // - - - - - - - - - - - - - - - - - - - -
  cd.createTip = (element, tip) => {
    setTip(element, () => {
      showHoverTip(element, tip);
    });
  };

  // - - - - - - - - - - - - - - - - - - - -
  const setTip = (node, setTipCallBack) => {
    // The speed of the mouse could exceed
    // the speed of the fetch callback...
    // The mouse-has-left attribute caters for this.
    node.mouseenter(() => {
      node.removeClass('mouse-has-left');
      setTipCallBack();
    });
    node.mouseleave(() => {
      node.addClass('mouse-has-left');
      hoverTipContainer().empty();
    });
  };

  // - - - - - - - - - - - - - - - - - - - -
  const showHoverTip = ($node, tip) => {
    if (!$node.attr('disabled')) {
      if (!$node.hasClass('mouse-has-left')) {
        const hoverTip = $('<div>', { class:'hover-tip' }).html(tip);
        hoverTipContainer().html(hoverTip);
        nativePosition(hoverTip[0], 'left top+50', 'bottom right', $node);
      }
    }
  };

  // - - - - - - - - - - - - - - - - - - - -
  const hoverTipContainer = () => {
    return $('#hover-tip-container');
  };

})();
