/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Older katas did not distinguish between
  //   - an auto-revert (from an incorrect test prediction)
  //   - a [checkout]   (from the review page)
  // Both were light.revert == [id,index]

  cd.lib.appendTrafficLight = ($lights, light) => {
    let $light = $trafficLightImage(light);
    if (cd.lib.hasPrediction(light)) {
      $lights.append($predictImage(light));
      $lights.append($light);
    }
    else if (['pulling','timed_out','faulty'].includes(light.colour)) {
      $lights.append($light);
    }
    else if (cd.lib.isRevert(light)) {
      $lights.append($light = $revertImage(light));
    }
    else if (cd.lib.isCheckout(light)) {
      if (light.checkout.id === cd.kata.id) {
        $lights.append($light = $revertImage(light));
      } else {
        $lights.append($light = $checkoutImage(light));
      }
    }
    else {
      $lights.append($light);
    }
    return $light;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $trafficLightImage = (light) => {
    return $('<img>', {
      class: 'diff-traffic-light',
        src: `/images/traffic-light/${light.colour}.png`,
        alt: `${light.colour} traffic-light`,
      'data-colour': light.colour, // Revert needs colour+index
      'data-index': light.index
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.hasPrediction = (light) => light.predicted != undefined && light.predicted != 'none';

  const $predictImage = (light) => {
    const correct = (light.predicted === light.colour);
    const icon = correct ? 'tick' : 'cross';
    return $('<img>', {
      class: icon,
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
