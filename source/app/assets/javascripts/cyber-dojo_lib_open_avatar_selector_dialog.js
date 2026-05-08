/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.lib.openAvatarSelectorDialog = ($from, kataId, setupActiveAvatar) => {
    // Used by both app/views/kata and app/view/review
    const xPos = $from.offset().left;
    const yPos = $from.offset().top + 40;
    const dialog = document.createElement('dialog');
    dialog.id = 'avatar-selector-dialog';
    dialog.style.width = '405px';
    dialog.style.left = xPos + 'px';
    dialog.style.top = yPos + 'px';
    dialog.style.margin = '0';
    $(dialog).html(`
      <header>
        <span class="dialog-title">select an avatar</span>
        <button type="button" class="dialog-close">close</button>
      </header>
    `);
    $(dialog).append($makeAvatarSelectorHtml(dialog, kataId, setupActiveAvatar));
    $('body').append(dialog);
    $(dialog).on('close', () => dialog.remove());
    $('.dialog-close', dialog).click(() => dialog.close());
    dialog.showModal();
  };

  // - - - - - - - - - - - - - - - - - - - - - - - -
  const $makeAvatarSelectorHtml = (dialog, kataId, setupActiveAvatar) => {
    const $table = $('<table>');
    cd.review.getJSON('/group_joined', {id:kataId}, (joined) => {
      const active = cd.review.avatarsActive(joined);
      times(8, (x) => {
        const $tr = $('<tr>');
        times(8, (y) => {
          const $td = $('<td>');
          const index = x*8 + y;
          const $img = active[index]
            ? $makeColourAvatar(index, joined[index], dialog, setupActiveAvatar)
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
  const $makeColourAvatar = (index, avatar, dialog, setupActiveAvatar) => {
    const $img = $('<img>', {
        src: `/images/avatars/${index}.jpg`,
      class: 'small colour avatar',
        alt: `small colour avatar ${index}`
    });
    setupActiveAvatar($img, index, avatar, dialog);
    return $img;
  };

  return cd;

})(cyberDojo || {}, jQuery);
