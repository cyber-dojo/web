/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.forkDialog = (kata_id, index) => {
    const html = $('<div>', {
        id: 'fork-dialog',
      text: 'what kind of practice-session do you want to create?'
    });
    html.append($('<button>', {
         id: 'individual',
       type: 'button',
       text: 'individual'
    }).click(() => forkIndividual(kata_id, index)));
    html.append($('<button>', {
         id: 'group',
       type: 'button',
       text: 'group'
    }).click(() => forkGroup(kata_id, index)));

    $(html).dialog({
      title: cd.dialogTitle('fork'),
      autoOpen: true,
      modal: true,
      width: 350,
      closeOnEscape: true,
      buttons: {
        'close': function() {
          $(this).remove();
        }
      }
    });
  };

  const forkIndividual = (kata_id, index) => {
    $.ajax({
             url: '/forker/fork_individual',
            data: { id:kata_id, index:index },
        dataType: 'json',
           async: false,
         success: (response) => {
          if (response.forked) {
            const url = '/kata/edit/' + response.id;
            window.open(url);
          } else {
            //TODO:...
            alert(`individual-fork:failed :${response.reason}:`);
          }
        }
    });
  };

  const forkGroup = (kata_id, index) => {
    $.ajax({
             url: '/forker/fork_group',
            data: { id:kata_id, index:index },
        dataType: 'json',
           async: false,
         success: (response) => {
          if (response.forked) {
            const url = '/kata/group/' + response.id;
            window.open(url);
          } else {
            //TODO:...
            alert(`group-fork:failed :${response.reason}:`);
          }
        }
    });
  };

  //- - - - - - - - - - - - - - - - - - - -

  /*
  const forkWorkedDialog = function(params, index) {
    const id = params['id'];
    const phonetic = params['phonetic'];

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
  */

  return cd;

})(cyberDojo || {}, jQuery);
