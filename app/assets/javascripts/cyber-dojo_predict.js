/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  let predict = undefined; // 'on'|'off'

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  cd.predictOn = () => {
    return predict === 'on';
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  cd.setupPredictButton = (value) => {
    // Called from kata/edit to make the button visible.
    predict = value;
    cd.predictButton().show().click(() => showPredictOptionDialog());
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  cd.predictOptionChange = (checkbox) => {
    // Called from the predict-option dialog
    predict = checkbox.checked ? 'on' : 'off';
    $.post('/kata/set_predict', { id:cd.kataId(), value:predict });
    cd.updateTrafficLightsCount();
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  cd.predictTrafficLight = (input) => {
    // Called from the test-button handler
    if (cd.predictOn()) {
      // TODO: get from dialog
      alert('get red|amber|green prediction...')
      const prediction = 'amber';
      input.val(prediction);
    }
  };


  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const showPredictOptionDialog = () => {
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

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const blurb = () => {
    return [
      '<div id="predict-blurb">',
      'When on, you will be asked to predict',
      'the traffic-light colour.',
      '</div>'
    ].join(' ');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const light = (rag) => {
    return `<img class="predict" src="/traffic-light/image/${rag}_predicted_${rag}.png">`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const checkBoxHtml = () => {
    return [
      '<div id="predict-box">',
      '<div id="predict-text">predict&nbsp;traffic-light&nbsp;colour?</div>',
      '<input id="predict-checkbox"',
      'type="checkbox"',
      `class="regular-checkbox" ${predict==='on'?'checked':''}`,
      'onchange="cd.predictOptionChange(this)"/>',
      '<label for="predict-checkbox"></label>',
      '</div>'
    ].join(' ');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const trTd = (s) => {
    return `<tr><td>${s}</td><td></td></tr>`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  return cd;

})(cyberDojo || {}, jQuery);
