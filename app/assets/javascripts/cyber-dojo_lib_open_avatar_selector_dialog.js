/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

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

  return cd;

})(cyberDojo || {}, jQuery);
