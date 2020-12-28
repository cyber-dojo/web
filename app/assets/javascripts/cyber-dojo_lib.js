/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.urlParam = (name, fallBack) => {
    const params = new URLSearchParams(window.location.search);
    return params.get(name) || fallBack;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -

  cd.lib.isVisible = (event) => {
    // Used by both app/views/kata and app/view/review
    // Eg don't show event[0] == creation
    switch (event.colour) {
    case 'red':
    case 'amber':
    case 'green':
    case 'pulling':
    case 'timed_out':
    case 'faulty':
      return true;
    default:
      return false;
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -

  let avatarNamesCache = undefined;

  cd.lib.avatarName = (n) => {
    if (avatarNamesCache === undefined) {
      $.ajax({
              type: 'GET',
               url: '/images/avatars/names.json',
          dataType: 'json',
             async: false,
           success: (avatarsNames) => {
             avatarNamesCache = avatarsNames;
           }
      });
    }
    return avatarNamesCache[n];
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -

  cd.lib.openAvatarSelectorDialog = ($from, kataId, setupActiveAvatar) => {
    // Used by both app/views/kata and app/view/review
    const xPos = $from.offset().left;
    const yPos = $from.offset().top + 40;
    const $selector = $('<div>', { id:'avatar-selector-dialog'} );
    $selector
         .html($makeAvatarSelectorHtml($selector, kataId, setupActiveAvatar))
         .dialog({
                    width: 405,
                   height: 450,
                 autoOpen: true,
            closeOnEscape: true,
                    modal: true,
                 position: [ xPos,yPos ],
                    title: cd.dialogTitle('select an avatar'),
                    close: () => $selector.dialog('destroy')
          });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -
  const $makeAvatarSelectorHtml = ($selector, kataId, setupActiveAvatar) => {
    const $table = $('<table>');
    cd.review.getJSON('model', 'group_joined', {id:kataId}, (joined) => {
      const active = cd.review.avatarsActive(joined);
      times(8, (x) => {
        const $tr = $('<tr>');
        times(8, (y) => {
          const $td = $('<td>');
          const index = x*8 + y;
          const $img = active[index]
            ? $makeColourAvatar(index, joined[index], $selector, setupActiveAvatar)
            : $makeGreyAvatar(index);
          $td.append($img);
          $tr.append($td);
        });
        $table.append($tr);
      });
    });
    return $table;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -
  const times = (n, f) => {
    for (let i = 0; i < n; i++) {
      f(i);
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -
  const $makeGreyAvatar = (index) => {
    return $('<img>', {
        src: `/images/avatars/${index}.jpg`,
      class: 'small grey avatar',
        alt: `small grey avatar ${index}`
    });
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -
  const $makeColourAvatar = (index, avatar, $selector, setupActiveAvatar) => {
    const $img = $('<img>', {
        src: `/images/avatars/${index}.jpg`,
      class: 'small colour avatar',
        alt: `small colour avatar ${index}`
    });
    setupActiveAvatar($img, index, avatar, $selector);
    return $img;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.$makeAvatarImage = (avatarIndex) => {
    const $img = $('<img>', {
      class:'avatar-image',
        src:`/images/avatars/${avatarIndex}.jpg`,
        alt:`avatar number ${avatarIndex}`
    });
    cd.createTip($img, cd.lib.avatarName(avatarIndex));
    return $img;
  };

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
  const $predictImage = (light) => {
    const correct = (light.predicted === light.colour);
    const icon = correct ? 'tick' : 'cross';
    return $('<img>', {
      class: icon,
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
    if (light.checkout.avatarIndex != '') {
      return $('<img>', {
        class:`diff-traffic-light checkout ${light.colour}`,
          src:'/images/traffic-light/circle-checkout.png'
      });
    } else {
      return $('<span>');
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.hasPrediction = (light) => light.predicted != undefined && light.predicted != 'none';
  cd.lib.isRevert = (light) => light.revert != undefined;
  cd.lib.isCheckout = (light) => light.checkout != undefined;

  return cd;

})(cyberDojo || {}, jQuery);
