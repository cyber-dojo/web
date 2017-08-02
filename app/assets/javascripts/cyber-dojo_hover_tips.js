/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  let showTrafficLightHoverTipViaAjax = function(light) {
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

  let trafficLightCountHoverTip = function(node) {
    let avatarName = node.data('avatar-name');
    let reds = node.data('red-count');
    let ambers = node.data('amber-count');
    let greens = node.data('green-count');
    let timeOuts = node.data('timed-out-count');
    let trLight = function(colour, count) {
      return '' +
        '<tr>' +
          '<td>' +
            '<img' +
              " class='traffic-light-diff-tip-traffic-light-image'" +
              " src='/images/bulb_" + colour + ".png'>" +
          '</td>' +
          '<td>' +
             "&nbsp;<span class='traffic-light-diff-tip-tag " + colour + "'>" +
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
      let node = $(this);
      let setTipCallBack = function() {
        let tip = node.data('tip');
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

  cd.setTip = function(node, setTipCallBack) {
    node.mouseenter(function() {
      node.removeClass('mouse-has-left');
      setTipCallBack();
    });
    node.mouseleave(function() {
      node.addClass('mouse-has-left');
      $('.hover-tip', node).remove();
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.showHoverTip = function(node, tip) {
    // mouseenter may retrieve the tip via a slow ajax call
    // which means mouseleave could have already occurred
    // by the time the ajax returns to set the tip. The
    // mouse-has-left attribute reduces this race's chance.
    if (!node.hasClass('mouse-has-left')) {
      node.append($('<span class="hover-tip">' + tip + '</span>'));
      // dashboard auto-scroll requires forced positioning.
      $('.hover-tip').position({
        my: 'left top',
        at: 'right bottom',
        of: node
      });
    }
  };

  return cd;

})(cyberDojo || {}, jQuery);
