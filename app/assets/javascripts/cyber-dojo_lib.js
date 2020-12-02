/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  // Used by both app/views/kata and app/view/review

  // - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.isVisible = (event) => {
    // Eg don't show event[0] == creation
    switch (event.colour) {
    case 'pulling':
    case 'red':
    case 'amber':
    case 'green':
    case 'timed_out':
    case 'faulty':
      return true;
    default:
      return false;
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.appendLightQualifierImg = ($lights, light) => {
    // Older katas did not distinguish between
    //   - an auto-revert, from an incorrect test prediction
    //   - a [checkout], from the review page.
    // Both were light.revert == [id,index]
    if (cd.lib.isPredict(light)) {
      $lights.append($imgForPredict(light));
    }
    else if (cd.lib.isCheckout(light)) {
      $lights.append($imgForCheckout(light));
    }
    else if (cd.lib.isRevert(light)) {
      $lights.append($imgForRevert(light));
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.isPredict = (light) => light.predicted != undefined && light.predicted != 'none';
  cd.lib.isRevert = (light) => light.revert != undefined;
  cd.lib.isCheckout = (light) => light.checkout != undefined;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $imgForPredict = (light) => {
    const correct = (light.predicted === light.colour);
    const icon = correct ? 'tick' : 'cross';
    return $('<img>', {
      class: icon,
        src: `/images/traffic-light/circle-${icon}.png`
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $imgForRevert = (light) => {
    return $('<img>', {
      class: 'revert',
        src: '/images/traffic-light/circle-revert.png'
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $imgForCheckout = (light) => {
    if (light.checkout.avatarIndex != '') {
      return $('<img>', {
        class:'avatar-image checkout',
          src:`/images/avatars/${light.checkout.avatarIndex}.jpg`
      });
    } else {
      return $('<span>');
    }
  };

  return cd;

})(cyberDojo || {}, jQuery);
