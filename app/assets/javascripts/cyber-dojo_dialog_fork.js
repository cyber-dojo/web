/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.forkDialog = (kata_id, index) => {
    const $html = $('<div>', { class:'info' });
    $html.append($("<div>create a new exercise\r\nfrom this traffic-light's files</div>"));
    $html.append($('<button>', {
         id: 'individual',
       type: 'button',
       text: 'individual exercise'
    }).click(() => {
      fork(kata_id, index, 'individual', 'edit');
      $('#fork-dialog').remove();
    }));
    $html.append($('<button>', {
         id: 'group',
       type: 'button',
       text: 'group exercise'
    }).click(() => {
      fork(kata_id, index, 'group', 'group');
      $('#fork-dialog').remove();
    }));

    $('<div id="fork-dialog">').append($html).dialog({
      title: cd.dialogTitle('fork'),
      autoOpen: true,
      modal: true,
      width: 300,
      closeOnEscape: true,
    });
  };

  const fork = (kata_id, index, routeFrom, routeTo) => {
    $.ajax({
             url: `/forker/fork_${routeFrom}`,
            data: { id:kata_id, index:index },
        dataType: 'json',
           async: false,
         success: (response) => {
          if (response.forked) {
            window.open(`/kata/${routeTo}/${response.id}`);
          } else {
            cd.dialogError(response.message);
          }
        }
    });
  };

  return cd;

})(cyberDojo || {}, jQuery);
