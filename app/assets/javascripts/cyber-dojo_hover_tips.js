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

  const hoverTipContainer = () => {
    return $('#hover-tip-container');
  };

  const removeAllHoverTips = () => {
    $('.hover-tip',hoverTipContainer()).remove();
  };

  cd.setTip = (node, setTipCallBack) => {
    node.mouseenter(() => {
      //setTimeout(removeAllHoverTips, 5000);
      setTipCallBack();
    });
    node.mouseleave(() => {
      removeAllHoverTips();
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
      // position() is the jQuery UI plug-in
      // https://jqueryui.com/position/
      // Note: dashboard auto-scroll requires forced positioning.
      // at:'center' matches the time-tick tool-tip's position
      const htc = hoverTipContainer();
      $('.hover-tip',htc).remove();
      htc.append($('<span/>', {
        'class': 'hover-tip'
      }).html(tip).position({
        my: 'left top',
        at: 'center bottom',
        of: node,
        collision: 'none'
      }));
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
