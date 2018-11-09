/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  cd.forkDialog = (kata_id, index) => {
    const args = {
          id: kata_id,
       index: index
    };
    $.getJSON('/forker/fork', args, (response) => {
      if (response.forked) {
        forkWorkedDialog(response, index);
      } else {
        forkFailedDialog(response, index);
      }
    });
  };

  //- - - - - - - - - - - - - - - - - - - -

  const forkWorkedDialog = function(params, index) {
    const id = params['id'];
    const phonetic = params['phonetic'];

    cd.forkJoin = () => {
      // async:false prevents window.open(url) causing a blocked popup
      $.ajax({
             url: '/id_join/drop_down',
        dataType: 'json',
           async: false,
            data: { id: id },
         success: function(dojo) {
           // assuming dojo.exists
           // assuming !dojo.full
           const url = '/kata/edit/' + dojo.id;
           window.open(url);
         }
      });
    };

    cd.forkDashboard = () => {
      const url = '/dashboard/show/' + id;
      window.open(url);
    };

    const html = '' +
      '<div>A new session has been setup from ' + id + ' ' + index + ':</div>' +
      "<div id='dojo-id'>" + id.substring(0,6) + '</div>' +
      "<div id='phonetic-dojo-id'>" + phonetic + '</div>' +
      '<table>' +
      tr_td('<button type="button" onClick="cd.forkJoin();">' +
         'join the new session' +
      '</button>') +
      tr_td('<button type="button" onClick="cd.forkDashboard();">' +
        'open its dashboard' +
      '</button>') +
      '</table>';

    $('<div id="fork-dialog">')
      .html(html)
      .dialog({
        title: cd.dialogTitle('fork succeeded'),
        autoOpen: true,
        modal: true,
        width: 500,
        closeOnEscape: true,
        buttons: {
          'close': function() {
            $(this).remove();
          }
        }
      });
  };

  //- - - - - - - - - - - - - - - - - - - -

  const forkFailedDialog = (data, tag) => {
    const message =
      'Could not setup a new session from ' + ' ' + tag + '.' + '<br/>' +
      data.reason + ' does not exist.';
    $('<div>')
      .html(message)
      .dialog({
                title: cd.dialogTitle('fork failed'),
             autoOpen: true,
        closeOnEscape: true,
                modal: true,
                width: 450,
              buttons: { ok: function() { $(this).remove(); } }
      });
  };

  //- - - - - - - - - - - - - - - - - - - -

  const tr_td = (text) => {
    return '<tr><td>' + text + '</td></tr>';
  };

  //- - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
