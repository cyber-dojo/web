/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.forkDialog = (kataId, index) => {
    const $html = $('<div>', { class:'info' });
    $html.append($("<div>create a new exercise\r\nfrom this traffic-light's files</div>"));
    $html.append($('<button>', {
         id: 'individual',
       type: 'button',
       text: 'individual exercise'
    }).click(() => {
      fork(kataId, index, 'individual');
      $('#fork-dialog').remove();
    }));
    $html.append($('<button>', {
         id: 'group',
       type: 'button',
       text: 'group exercise'
    }).click(() => {
      fork(kataId, index, 'group');
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

  const fork = (kataId, index, type) => {
    $.ajax({
            type: 'POST',
             url: `/forker/fork_${type}?id=${kataId}&index=${index}`,
        dataType: 'json', // format we want response in
           async: false,
         success: (response) => {
           if (response.forked) {
             window.open(`/creator/enter?id=${response.id}`);
           } else {
             cd.dialogError(response.message);
           }
        }
    });
  };

  return cd;

})(cyberDojo || {}, jQuery);
