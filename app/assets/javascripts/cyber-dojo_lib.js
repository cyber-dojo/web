/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.urlParam = (name, fallBack) => {
    const params = new URLSearchParams(window.location.search);
    return params.get(name) || fallBack;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -
  // Used by both app/views/kata and app/view/review

  cd.lib.isVisible = (event) => {
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
  // Used by both app/views/kata and app/view/review

  cd.lib.openAvatarSelectorDialog = ($from, kataId, setupActiveAvatar) => {
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
    cd.setupAvatarNameHoverTip($img, '', avatarIndex, '');
    return $img;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.appendImageIfPrediction = ($lights, light) => {
    // Older katas did not distinguish between
    //   - an auto-revert (from an incorrect test prediction)
    //   - a [checkout]   (from the review page)
    // Both were light.revert == [id,index]
    if (cd.lib.isPredict(light)) {
      $lights.append($imgForPredict(light));
    }
    else if (cd.lib.isRevert(light)) {
      $lights.append($imgForRevert(light));
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cd.lib.appendImageIfCheckout = ($lights, light) => {
    if (cd.lib.isCheckout(light)) {
      $lights.append($imgForCheckout(light));
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
