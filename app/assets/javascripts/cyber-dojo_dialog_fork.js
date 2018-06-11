/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.forkDialog = (kata_id, avatar_name, tag) => {
    const forkParams = {
          id: kata_id,
      avatar: avatar_name,
         tag: tag
    };
    $.getJSON('/forker/fork', forkParams, (data) => {
      if (data.forked) {
        forkWorkedDialog(data, avatar_name, tag);
      } else {
        forkFailedDialog(data, avatar_name, tag);
      }
    });
  };

  //- - - - - - - - - - - - - - - - - - - -

  const forkWorkedDialog = function(params, avatar_name, tag) {
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
           const url = '/kata/edit/' + dojo.id + '?avatar=' + dojo.avatarName;
           window.open(url);
         }
      });
    };

    cd.forkDashboard = () => {
      const url = '/dashboard/show/' + id;
      window.open(url);
    };

    const html = '' +
      '<div>A new session has been setup from ' + avatar_name + ' ' + tag + ':</div>' +
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

  const forkFailedDialog = (data, avatar_name, tag) => {
    const message =
      'Could not setup a new session from ' + avatar_name + ' ' + tag + '.' + '<br/>' +
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
