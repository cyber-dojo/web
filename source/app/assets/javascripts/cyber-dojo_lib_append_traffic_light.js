/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Older katas did not distinguish between
  //   - an auto-revert (from an incorrect test prediction)
  //   - a [checkout]   (from the review page)
  // Both were light.revert == [id,index]

  cd.lib.appendTrafficLight = ($lights, light, option={isCurrentIndex:false}) => {
    //alert(`appendTrafficLight ${JSON.stringify(light)}`);
    if (cd.lib.hasPrediction(light)) {
      $lights.append($predictImage(light));
    } 
    else if (cd.lib.isRevert(light)) {
      $lights.append($revertImage(light));
    }
    else if (cd.lib.isCheckout(light)) {
      $lights.append($checkoutImage(light));
    } 

    const $light = $trafficLightImage(light);
    if (option.isCurrentIndex) {
      const $box = $('<div>', { class:'current-light-box' });
      $box.append($light, $lightMarker(light.colour));
      $lights.append($box);
    } 
    else {
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
    if (cd.lib.isLight(light)) {
      return $ragImage(light);
    } else {
      return $fileEventImage(light);
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $ragImage = (light) => {
    return $('<img>', {
      class: 'diff-traffic-light',
        src: `/images/traffic-light/${light.colour}.png`,
        alt: `${light.colour} traffic-light`,
      'data-colour': light.colour, // Revert needs colour+index, TODO: no longer true
      'data-index': light.index
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $fileEventImage = (event) => {
    return $('<img>', {
      class: 'diff-traffic-light',
        src: `/images/traffic-light/${event.colour}.png`,
        alt: `${event.colour} traffic-light`,
      'data-colour': event.colour,
      'data-index': event.index
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.hasPrediction = (light) => ['red','amber','green'].includes(light.predicted);

  const $predictImage = (light) => {
    const correct = (light.predicted === light.colour);
    const icon = correct ? 'tick' : `cross-${light.predicted}`;
    return $('<img>', {
      class: `${icon} ${light.predicted}`,
        src: `/images/traffic-light/circle-${icon}.png`
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.isRevert = (light) => {
    // TODO: also revert if light.checkout.avatarIndex == current avatar's index
    return light.checkout && light.checkout.avatarIndex == '';
  };

  const $revertImage = (light) => {
    return $('<img>', {
      class: `diff-traffic-light revert ${light.colour}`,
        src: '/images/traffic-light/circle-revert.png'
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.isCheckout = (light) => {
    return light.checkout != undefined;
  };

  const $checkoutImage = (light) => {
    return $('<img>', {
      class:`diff-traffic-light checkout ${light.colour}`,
        src:'/images/traffic-light/circle-checkout.png'
    });
  };

  return cd;

})(cyberDojo || {}, jQuery);
