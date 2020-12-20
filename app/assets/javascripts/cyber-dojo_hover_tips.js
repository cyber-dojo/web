/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.setupAvatarNameHoverTip = ($element, textBefore, avatarIndex, textAfter) => {
    cd.setTip($element, () => {
      $.getJSON('/images/avatars/names.json', '', (avatarsNames) => {
        const avatarName = avatarsNames[avatarIndex];
        const tip = `${textBefore}${avatarName}${textAfter}`;
        cd.showHoverTip($element, tip);
      });
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.setupTrafficLightTip = ($light, colour, avatarIndex, kataId, wasIndex, nowIndex) => {
    cd.setTip($light, () => {
      const args = { id:kataId, was_index:wasIndex, now_index:nowIndex };
      $.getJSON('/differ/diff_summary', args, (data) => {
        const diff = data.diff_summary;
        const $tip = $trafficLightTip($light, colour, nowIndex, avatarIndex(), diff);
        cd.showHoverTip($light, $tip);
      });
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  const $trafficLightTip = ($light, colour, index, avatarIndex, diff) => {
    const $holder = $(document.createDocumentFragment());
    $holder.append($trafficLightSummary($light, colour, index, avatarIndex));
    $holder.append($diffLinesTable(diff));
    return $holder;
  };

  // - - - - - - - - - - - - - - - - - - - -

  const $trafficLightSummary = ($light, colour, index, avatarIndex) => {
    const $tr = $('<tr>');
    $tr.append($avatarImageTd(avatarIndex));
    $tr.append($trafficLightCountTd(colour, index));
    $tr.append($trafficLightImageTd(colour));
    return $('<table>').append($tr);
  };

  // - - - - - - - - - - - - - - - - - - - -

  const $avatarImageTd = (avatarIndex) => {
    const $td = $('<td>');
    if (avatarIndex != '') {
      const $img = $('<img>', {
          src:`/images/avatars/${avatarIndex}.jpg`,
        class:'diff-hover-tip'
      });
      $td.append($img);
    }
    return $td;
  };

  // - - - - - - - - - - - - - - - - - - - -

  const $trafficLightCountTd = (colour, index) => {
    const $count = $('<span>', {
      class:`traffic-light-count ${colour}`
    }).text(index);
    return $('<td>').append($count);
  };

  // - - - - - - - - - - - - - - - - - - - -

  const $trafficLightImageTd = (colour) => {
    const $img = $('<img>', {
        src:`/images/traffic-light/${colour}.png`,
      class:'diff-hover-tip'
    });
    return $('<td>').append($img);
  };

  // - - - - - - - - - - - - - - - - - - - -

  const $diffLinesTable = (diffs) => {
    const $table = $('<table>', { class:'filenames' });
    const $tr = $('<tr>');
    // column icons
    $tr.append($linesCountIconTd('deleted', '&mdash;'));
    $tr.append($linesCountIconTd('added', '+'));
    $tr.append($linesCountIconTd('same', '='));
    $tr.append($('<td>'));
    $tr.append($('<td>'));
    $table.append($tr);
    // cyber-dojo.sh cannot be deleted so there is always one file
    const filenames = diffs.map(diff => diffFilename(diff));
    cd.sortedFilenames(filenames).forEach(filename => {
      const fileDiff = diffs.find(diff => diffFilename(diff) === filename);
      const $tr = $('<tr>');
      $tr.append($lineCountTd('deleted', fileDiff));
      $tr.append($lineCountTd('added', fileDiff));
      $tr.append($lineCountTd('same', fileDiff));
      $tr.append($diffTypeTd(fileDiff));
      $tr.append($diffFilenameTd(fileDiff));
      $table.append($tr);
    });
    return $table;
  };

  // - - - - - - - -

  const $linesCountIconTd = (type, glyph) => {
    const $icon = $('<div>', {
      class:`diff-line-count-icon ${type}`
    }).html(glyph);
    return $('<td>').append($icon);
  };

  // - - - - - - - -

  const $lineCountTd = (type, file) => {
    const lineCount = file.line_counts[type];
    const css = lineCount > 0 ? type : '';
    const $count = $('<div>', {
      class:`diff-line-count ${css}`,
      disabled:'disabled'
    });
    $count.html(lineCount > 0 ? lineCount : '&nbsp;');
    return $('<td>').append($count);
  };

  // - - - - - - - -

  const $diffTypeTd = (diff) => {
    const $type = $('<div>', {
      class:`diff-type-marker ${diff.type}`
    });
    return $('<td>').append($type);
  };

  // - - - - - - - -

  const $diffFilenameTd = (diff) => {
    const $filename = $('<div>', { class:`diff-filename ${diff.type}` });
    $filename.text(diffFilename(diff));
    return $('<td>').append($filename);
  };

  const diffFilename = (diff) => {
    if (diff.type === 'deleted') {
      return diff.old_filename;
    } else {
      return diff.new_filename;
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  const hoverTipContainer = () => {
    return $('#hover-tip-container');
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.removeTip = ($node) => {
    hoverTipContainer().empty();
  };

  cd.createTip = (node, tip, where) => {
    node.off('mouseenter mouseleave');
    cd.setTip(node, () => {
      if (typeof tip === 'string') {
        cd.showHoverTip(node, tip, where);
      }
      if (typeof tip === 'function') {
        cd.showHoverTip(node, tip(), where);
      }
    });
  };

  cd.setTip = (node, setTipCallBack) => {
    // The speed of the mouse could easily exceed
    // the speed of the getJSON callback...
    // The mouse-has-left attribute caters for this.
    node.mouseenter(() => {
      node.removeClass('mouse-has-left');
      setTipCallBack(node);
    });
    node.mouseleave(() => {
      node.addClass('mouse-has-left');
      cd.removeTip();
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.showHoverTip = (node, tip, where) => {
    if (where === undefined) {
      where = {};
    }
    if (where.my === undefined) { where.my = 'top'; }
    if (where.at === undefined) { where.at = 'bottom'; }
    if (where.of === undefined) { where.of = node; }

    if (!node.attr('disabled')) {
      if (!node.hasClass('mouse-has-left')) {
        // position() is the jQuery UI plug-in
        // https://jqueryui.com/position/
        const hoverTip = $('<div>', {
          'class': 'hover-tip'
        }).html(tip).position({
          my: where.my,
          at: where.at,
          of: where.of,
          collision: 'fit'
        });
        hoverTipContainer().html(hoverTip);
      }
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
