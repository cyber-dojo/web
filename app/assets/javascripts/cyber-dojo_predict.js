/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  let predict = undefined; // 'on'|'off'

  cd.setupPredictButton = (value) => {
    predict = value;
    cd.predictButton().show().click(() => predictDialog());
  };

  cd.predictHandler = (checkbox) => {
    predict = checkbox.checked ? 'on' : 'off';
    $.post('/kata/set_predict', { id:cd.kataId(), value:predict });
  };

  const predictDialog = () => {
    let html = '';
    html += '<div>'
    html += '<table>';
    html += `<tr><td>${light('red')}</td><td rowspan="3">${blurb()}</td></tr>`;
    html += trTd(light('amber'));
    html += trTd(light('green'));
    html += '</table>';
    html += checkBoxHtml();
    html += '</div>';

    const node = $(html);
    node.dialog({
              width: '300',
           autoOpen: true,
      closeOnEscape: true,
              modal: true,
              title: cd.dialogTitle('predict?'),
            buttons: { close: () => {
                node.remove();
                cd.editorRefocus();
              }
            },
        beforeClose: event => {
          if (event.keyCode === $.ui.keyCode.ESCAPE) {
            node.remove();
            cd.editorRefocus();
            return true;
          }
        }
    });
  };

  const blurb = () => {
    return [
      '<div id="predict-blurb">',
      'When on, each test submission will ask you to',
      'predict the colour of the forthcoming traffic-light.',
      '</div>'
    ].join(' ');
  };

  const light = (rag) => {
    return `<img class="predict" src="/traffic-light/image/${rag}_predicted_${rag}.png">`;
  };

  const checkBoxHtml = () => {
    return [
      '<div id="predict-box">',
      '<div id="predict-text">predict&nbsp;traffic-light&nbsp;colour?</div>',
      '<input id="predict-checkbox"',
      'type="checkbox"',
      `class="regular-checkbox" ${predict==='on'?'checked':''}`,
      'onchange="cd.predictHandler(this)"/>',
      '<label for="predict-checkbox"></label>',
      '</div>'
    ].join(' ');
  };

  const trTd = (s) => {
    return `<tr><td>${s}</td><td></td></tr>`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
