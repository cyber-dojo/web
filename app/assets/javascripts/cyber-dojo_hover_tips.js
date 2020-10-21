/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.setupTrafficLightTip = ($light, kataId, wasIndex, nowIndex) => {
    cd.setTip($light, () => {
      const args = { id:kataId, was_index:wasIndex, now_index:nowIndex };
      $.post('/differ/diff_summary', JSON.stringify(args), (data) => {
        cd.showHoverTip($light, tipHtml($light, data.diff_summary));
      });
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  const tipHtml = ($light, diffSummary) => {
    const avatarIndex = $light.data('avatar-index');
    const colour = $light.data('colour');
    const number = $light.data('number');
    return `<table>
             <tr>
               <td>${avatarImage(avatarIndex)}</td>
               <td><span class="traffic-light-count ${colour}">${number}</span></td>
               <td><img src="/images/traffic-light/${colour}.png"
                      class="traffic-light-diff-tip-traffic-light-image"></td>
             </tr>
           </table>
           ${diffLinesHtmlTable(diffSummary)}`;
  };

  // - - - - - - - - - - - - - - - - - - - -

  const avatarImage = (avatarIndex) => {
    if (avatarIndex === '') {
      return '';
    } else {
      return `<img src="/images/avatars/${avatarIndex}.jpg"
                 class="traffic-light-diff-tip-avatar-image">`;
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  const diffLinesHtmlTable = (files) => {
    const chunks = $('<table>');
    Object.keys(files).forEach(function(filename) {
      chunks.append(
        `<tr>
          <td>
            <div class="traffic-light-diff-tip-line-count-deleted some button">
              ${files[filename].deleted}
            </div>
          </td>
          <td>
            <div class="traffic-light-diff-tip-line-count-added some button">
              ${files[filename].added}
            </div>
          </td>
          <td>&nbsp;${filename}</td>
        </tr>`
      ); //append
    }); // forEach
    return chunks.get(0).outerHTML;
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.setupHoverTips = function(nodes) {
    nodes.each(function() {
      const node = $(this);
      const setTipCallBack = () => {
        const tip = node.data('tip');
        if (tip === 'traffic_light_count') {
          cd.showHoverTip(node, trafficLightCountHoverTip(node));
        } else {
          cd.showHoverTip(node, tip);
        }
      };
      cd.setTip(node, setTipCallBack);
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  const trafficLightCountHoverTip = (node) => {
    // for dashboard avatar totalCount
    const reds = node.data('red-count');
    const ambers = node.data('amber-count');
    const greens = node.data('green-count');
    const timeOuts = node.data('timed-out-count');
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
    return html;
  };

  // - - - - - - - - - - - - - - - - - - - -

  const hoverTipContainer = () => {
    return $('#hover-tip-container');
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
      hoverTipContainer().empty();
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.createTip = (element, tip) => {
    cd.setTip(element, () => {
      cd.showHoverTip(element, tip);
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.showHoverTip = (node, tip) => {
    if (!node.attr('disabled')) {
      if (!node.hasClass('mouse-has-left')) {
        // position() is the jQuery UI plug-in
        // https://jqueryui.com/position/
        const hoverTip = $('<div>', {
          'class': 'hover-tip'
        }).html(tip).position({
          my: 'top',
          at: 'bottom',
          of: node,
          collision: 'fit'
        });
        hoverTipContainer().html(hoverTip);
      }
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
