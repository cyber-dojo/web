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
    else if (cd.lib.isRevert(light) || cd.lib.isAutoRevert(light)) {
      $lights.append($revertImage(light));
    }
    else if (cd.lib.isCheckout(light)) {
      $lights.append($checkoutImage(light));
    } 

    const $light = $trafficLightImage(light);
    if (option.isCurrentIndex) {
      const $box = $('<div>', { class:'current-light-box' });
      $box.append($light, $lightMarker(light));
      $lights.append($box);
    } 
    else {
      $lights.append($light);
    }
    return $light;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -
  // The underbar beneath the current index. Its name must track the
  // image chosen by $trafficLightImage: the colour for a rag-light
  // (marker_red/amber/green.png), or the file-event icon name for an
  // inter-file icon (marker_file_test/file_code.png).
  const $lightMarker = (light) => {
    const name = cd.lib.isLight(light) ? light.colour : fileEventIcon(light);
    return $('<img>', {
      src: `/images/traffic-light/marker_${name}.png`,
      alt: 'current light marker',
       id: 'traffic-light-marker'
    });
  };

  const $trafficLightImage = (light) => {
    if (cd.lib.isLight(light)) {
      return $ragImage(light);
    } 
    else {
      return $fileEventImage(light);
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
  // The icon name for an inter-file event: test files and source files
  // get distinct icons. Shared by $fileEventImage and $lightMarker so the
  // icon and its underbar always match.
  const fileEventIcon = (event) => {
    const filename = event.colour === 'file_rename' ? event.new_filename : event.filename;
    return cd.isTestFile(filename) ? 'file_test' : 'file_code';
  };

  const $fileEventImage = (event) => {
    const icon = fileEventIcon(event);
    return $('<img>', {
      class: 'diff-traffic-light',
        src: `/images/traffic-light/${icon}.png`,
        alt: icon,
      'data-colour': event.colour,
      'data-index': event.index
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.hasPrediction = (light) => {
    return ['red','amber','green'].includes(light.predicted);
  };

  cd.lib.isAutoRevert = (light) => {
    // Auto-Revert is from [test] page, from incorrect prediction.
    return light.revert;
  };

  cd.lib.isRevert = (light) => {
    // Revert is from [review] page, go back to one of your own previous traffic-lights.
    return light.checkout && light.checkout.id == cd.kata.id;
  };

  cd.lib.isCheckout = (light) => {
    // Checkout is from [review] page, go back to different avatar's traffic-light.
    return light.checkout && light.checkout.id != cd.kata.id;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $predictImage = (light) => {
    const correct = (light.predicted === light.colour);
    const icon = correct ? 'tick' : `cross-${light.predicted}`;
    return $('<img>', {
      class: `${icon} ${light.predicted}`,
        src: `/images/traffic-light/circle-${icon}.png`
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $revertImage = (light) => {
    return $('<img>', {
      class: `diff-traffic-light revert ${light.colour}`,
        src: '/images/traffic-light/circle-revert.png'
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  const $checkoutImage = (light) => {
    return $('<img>', {
      class:`diff-traffic-light checkout ${light.colour}`,
        src:'/images/traffic-light/circle-checkout.png'
    });
  };

  return cd;

})(cyberDojo || {}, jQuery);
