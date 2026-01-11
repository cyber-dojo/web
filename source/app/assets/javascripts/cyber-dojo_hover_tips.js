/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.setupTrafficLightTip = ($light, light, kataId, wasIndex, nowIndex) => {
    setTip($light, () => {
      const args = { id:kataId, was_index:wasIndex, now_index:nowIndex };
      $.getJSON('/differ/diff_summary', args, (data) => {
        const diff = data.diff_summary;
        const $tip = $trafficLightTip(light, kataId, diff);
        showHoverTip($light, $tip);
      });
    });
  };

  const $trafficLightTip = (light, kataId, diff) => {
    const $holder = $(document.createDocumentFragment());
    $holder.append($trafficLightSummary(light, kataId));
    $holder.append($diffLinesTable(diff));
    return $holder;
  };

  const $trafficLightSummary = (light, kataId) => {
    const $tr = $('<tr>');
    $tr.append($trafficLightIndexTd(light));
    $tr.append($trafficLightImageTd(light));
    $tr.append($('<td class="mini-text">').html(miniTextInfo(kataId, light)));
    return $('<table>').append($tr);
  };

  const $trafficLightIndexTd = (light) => {
    const $count = $('<span>', {
      class:`traffic-light-count ${light.colour}`
    }).text(cd.lib.dottedIndex(light));
    return $('<td>').append($count);
  };

  const $trafficLightImageTd = (light) => {
    const $img = $('<img>', {
        src:`/images/traffic-light/${light.colour}.png`,
      class:'diff-hover-tip'
    });
    return $('<td>').append($img);
  };

  const miniTextInfo = (kataId, light) => {
    switch (light.colour) {
      case 'create':      return 'Kata created';
      case 'pulling':     return 'Image being prepared';
      case 'timed_out':   return 'Timed out';
      case 'file_create': return 'File created';
      case 'file_delete': return 'File deleted';
      case 'file_rename': return 'File renamed';    
      case 'file_edit':   return 'File edited';
    }
    if (light.colour == 'faulty') {
      const cssRed = cssColour('red');
      const cssAmber = cssColour('amber');
      const cssGreen = cssColour('green');
      return `Fault! not ${cssRed}, ${cssAmber}, or ${cssGreen}`;
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
    else {
      return cssColour(light.colour);
    }
  };

  const trafficLightPredictInfo = (light) => {
    const colour = light.colour
    const predicted = light.predicted;
    return `Predicted ${cssColour(predicted)}, got ${cssColour(colour)}`;
  };

  const trafficLightRevertInfo = (light) => {
    const colour = cssColour(light.colour);
    const index = cssColour(light.colour, light.major_index - 2)
    return `Auto-reverted to ${colour} ${index}`;
  };

  const trafficLightCheckoutInfo = (kataId, light) => {
    const colour = cssColour(light.colour);
    const index = cssColour(light.colour, light.checkout.index);
    if (kataId === light.checkout.id) {
      return `Reverted to ${colour} ${index}`;
    } 
    else {
      const name = cd.lib.avatarName(light.checkout.avatarIndex);
      return `Checked-out ${name}'s ${colour} ${index}`;
    }
  };

  const cssColour = (colour, text = capitalized(colour)) => {
    return `<span class="${colour}">${text}</span>`;
  };

  const capitalized = (word) => {
    return word[0].toUpperCase() + word.substring(1);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
    // cyber-dojo.sh cannot be deleted so there is always at least one file
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

  const $linesCountIconTd = (type, glyph) => {
    const $icon = $('<div>', {
      class:`diff-line-count-icon ${type}`
    }).html(glyph);
    return $('<td>').append($icon);
  };

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

  const $diffTypeTd = (diff) => {
    const $type = $('<div>', {
      class:`hover diff-type-marker ${diff.type}`
    });
    return $('<td>').append($type);
  };

  const $diffFilenameTd = (diff) => {
    const $filename = $('<div>', { class:`hover diff-filename ${diff.type}` });
    $filename.text(diffFilename(diff));
    return $('<td>').append($filename);
  };

  const diffFilename = (diff) => {
    if (diff.type === 'deleted') {
      return diff.old_filename;
    } 
    else {
      return diff.new_filename;
    }
  };

  const hoverTipContainer = () => {
    return $('#hover-tip-container');
  };

  cd.removeTip = () => {
    hoverTipContainer().empty();
  };

  cd.createTip = ($node, tip, where) => {
    $node.off('mouseenter mouseleave');
    setTip($node, () => showHoverTip($node, tip, where));
  };

  const setTip = ($node, setTipCallBack) => {
    // The speed of the mouse can exceed
    // the speed of the getJSON callback...
    // The mouse-has-left attribute caters for this.
    $node.mouseenter(() => {
      $node.removeClass('mouse-has-left');
      setTipCallBack($node);
    });
    $node.mouseleave(() => {
      $node.addClass('mouse-has-left');
      cd.removeTip();
    });
  };

  const showHoverTip = ($node, tip, where) => {
    if (where === undefined) {
      where = {};
    }
    if (where.my === undefined) { where.my = 'top'; }
    if (where.at === undefined) { where.at = 'bottom'; }
    if (where.of === undefined) { where.of = $node; }
    if (!$node.attr('disabled') && !$node.hasClass('mouse-has-left')) {
      if (typeof tip === 'function') {
        tip = tip();
      }
      // position() is the jQuery UI plug-in
      // https://jqueryui.com/position/
      const $hoverTip =
        $('<div>', { class: 'hover-tip' })
          .html(tip)
          .position({
            my: where.my,
            at: where.at,
            of: where.of,
            collision: 'flip flip'
          });
      hoverTipContainer().html($hoverTip);
    }
  };

  return cd;

})(cyberDojo || {}, jQuery);
