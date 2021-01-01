/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Older katas did not distinguish between
  //   - an auto-revert (from an incorrect test prediction)
  //   - a [checkout]   (from the review page)
  // Both were light.revert == [id,index]

  cd.lib.appendTrafficLight = ($lights, light, option={isCurrentIndex:false}) => {
    if (cd.lib.hasPrediction(light)) {
      $lights.append($predictImage(light));
    }
    const $light = $trafficLightImage(light);
    if (option.isCurrentIndex) {
      const $lightBox = $('<div>', { class:'current-light-box' });
      $lightBox.append($light, $lightMarker(light.colour));
      $lights.append($lightBox);
    } else {
      $lights.append($light);
    }
    return $light;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -
  const $lightMarker = (colour) => {
    return $('<img>', {
      src: `/images/traffic-light/marker_${colour}.png`,
      alt: 'current light marker',
       id: 'traffic-light-marker'
    });
  };

  const $trafficLightImage = (light) => {
    if (cd.lib.isRevert(light)) {
      return $revertImage(light);
    }
    else if (cd.lib.isCheckout(light)) {
      if (light.checkout.id === cd.kata.id) {
        return $revertImage(light);
      } else {
        return $checkoutImage(light);
      }
    } else {
      return $ragImage(light);
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $ragImage = (light) => {
    return $('<img>', {
      class: 'diff-traffic-light',
        src: `/images/traffic-light/${light.colour}.png`,
        alt: `${light.colour} traffic-light`,
      'data-colour': light.colour, // Revert needs colour+index
      'data-index': light.index
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.hasPrediction = (light) => ['red','amber','green'].includes(light.predicted);

  const $predictImage = (light) => {
    const correct = (light.predicted === light.colour);
    const icon = correct ? 'tick' : 'cross';
    return $('<img>', {
      class: `${icon} ${light.predicted}`,
        src: `/images/traffic-light/circle-${icon}.png`
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.isRevert = (light) => light.revert != undefined;

  const $revertImage = (light) => {
    return $('<img>', {
      class: `diff-traffic-light revert ${light.colour}`,
        src: '/images/traffic-light/circle-revert.png'
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.isCheckout = (light) => light.checkout != undefined;

  const $checkoutImage = (light) => {
    if (light.checkout.avatarIndex != '') {
      return $('<img>', {
        class:`diff-traffic-light checkout ${light.colour}`,
          src:'/images/traffic-light/circle-checkout.png'
      });
    } else {
      return $('<span>');
    }
  };

  return cd;

})(cyberDojo || {}, jQuery);
