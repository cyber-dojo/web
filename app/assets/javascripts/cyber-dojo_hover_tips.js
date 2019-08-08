/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.setupTrafficLightTip = ($light, id, wasIndex, nowIndex) => {
    const args = { id:id, was_index:wasIndex, now_index:nowIndex };
    cd.setTip($light, () => {
      $.getJSON('/tipper/traffic_light_tip', args, (response) => {
        cd.showHoverTip($light, response.html);
      });
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  const trafficLightCountHoverTip = (node) => {
    const reds = node.data('red-count');
    const ambers = node.data('amber-count');
    const greens = node.data('green-count');
    const timeOuts = node.data('timed-out-count');
    const trLight = (colour, count) => {
      return '' +
        '<tr>' +
          '<td>' +
            '<img' +
              " class='traffic-light-diff-tip-traffic-light-image'" +
              ` src='/images/bulb_${colour}.png'>` +
          '</td>' +
          '<td>' +
             `<span class='traffic-light-diff-tip-tag ${colour}'>` +
              count +
             '</span>' +
          '</td>' +
        '</tr>';
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

  cd.setTip = (node, setTipCallBack) => {
    node.mouseenter(() => {
      node.removeClass('mouse-has-left');
      setTipCallBack();
    });
    node.mouseleave(() => {
      node.addClass('mouse-has-left');
      $('.hover-tip', node).remove();
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
    // mouseenter may retrieve the tip via a slow ajax call
    // which means mouseleave could have already occurred
    // by the time the ajax returns to set the tip. The
    // mouse-has-left attribute reduces this race's chance.
    const allLights = node.closest('#traffic-lights');
    if (!node.hasClass('mouse-has-left')) {
      if (!node.attr('disabled')) {
        node.append($(`<span class="hover-tip">${tip}</span>`));
        // This is the jQuery UI plug-in
        // https://jqueryui.com/position/
        // Note: dashboard auto-scroll requires forced positioning.
        // at:'center' is important to match the position of the time-tick tool-tip
        $('.hover-tip').position({
          my: 'left top',
          at: 'center',
          of: node,
          within: allLights,
          collision: 'fit'
        });
      }
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
