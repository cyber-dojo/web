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
    switch (predict) {
      case 'on' :
        cd.predictButton().clickToggle(setPredictOff, setPredictOn);
        break;
      case 'off':
        cd.predictButton().clickToggle(setPredictOn, setPredictOff);
        break;
    }
    cd.predictButton().show();
  };

  const setPredictOn = () => setPredict('on');
  const setPredictOff = () => setPredict('off');

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const setPredict = (value) => {
    // Called from the predict-option dialog
    predict = value;
    $.post('/kata/set_predict', { id:cd.kataId(), value:predict });
    cd.updateTrafficLightsCount();
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  cd.predictTrafficLight = (input, handler) => {
    // Called from the test-button handler
    if (cd.predictOn()) {
      makePredictionDialog(input, handler);
    } else {
      handler();
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const makePredictionDialog = (input, handler) => {
    let html = '';
    html += '<div id="prediction-dialog">'
    html += '<table>';
    html += tr2('red',     redBlurb());
    html += tr2('amber', amberBlurb());
    html += tr2('green', greenBlurb());
    html += '</table>';
    html += '</div>';
    const node = $(html);
    $('img#predict-red',node).click(() => {
      input.val('red');
      node.remove();
      handler();
    });
    $('img#predict-amber',node).click(() => {
      input.val('amber');
      node.remove();
      handler();
    });
    $('img#predict-green',node).click(() => {
      input.val('green');
      node.remove();
      handler();
    });
    node.dialog({
              width: '300',
           autoOpen: true,
      closeOnEscape: true,
              modal: true,
              title: cd.dialogTitle('predict!'),
            buttons: { close: () => {
                node.remove();
              }
            },
        beforeClose: event => {
          if (event.keyCode === $.ui.keyCode.ESCAPE) {
            node.remove();
            return true;
          }
        }
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const redBlurb = () => {
    return [
      'red-blurb'
    ].join(' ');
  };
  const amberBlurb = () => {
    return [
      'amber-blurb'
    ].join(' ');
  };
  const greenBlurb = () => {
    return [
      'green-blurb'
    ].join(' ');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const lightImg = (rag) => {
    return `<img class="predict" id="predict-${rag}" src="/traffic-light/image/${rag}_predicted_${rag}.png">`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const tr2 = (rag, blurb) => {
    return `<tr><td>${lightImg(rag)}</td><td>${blurb}</td></tr>`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  return cd;

})(cyberDojo || {}, jQuery);
