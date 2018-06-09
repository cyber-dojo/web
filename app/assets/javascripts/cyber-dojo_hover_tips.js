/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  const showTrafficLightHoverTipViaAjax = (light) => {
    $.getJSON('/tipper/traffic_light_tip', {
           id: light.data('id'),
       avatar: light.data('avatar-name'),
      was_tag: light.data('was-tag'),
      now_tag: light.data('now-tag')
    }, function(response) {
      cd.showHoverTip(light, response.html);
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  const trafficLightCountHoverTip = (node) => {
    const avatarName = node.data('avatar-name');
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
              " src='/images/bulb_" + colour + ".png'>" +
          '</td>' +
          '<td>' +
             "<span class='traffic-light-diff-tip-tag " + colour + "'>" +
              count +
             '</span>' +
          '</td>' +
        '</tr>';
    };

    let html = '';
    html += '<img';
    html +=   " class='traffic-light-diff-tip-avatar-image'";
    html +=   " src='/images/avatars/" + avatarName + ".jpg'>";
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

  cd.setupHoverTip = function(nodes) {
    nodes.each(function() {
      const node = $(this);
      const setTipCallBack = function() {
        const tip = node.data('tip');
        if (tip == 'ajax:traffic_light') {
          showTrafficLightHoverTipViaAjax(node);
        } else if (tip == 'traffic_light_count') {
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
    if (!node.hasClass('mouse-has-left')) {
      if (!node.attr('disabled')) {
        node.append($('<span class="hover-tip">' + tip + '</span>'));
        // dashboard auto-scroll requires forced positioning.
        $('.hover-tip').position({
          my: 'left top',
          at: 'right bottom',
          of: node
        });
      }
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
