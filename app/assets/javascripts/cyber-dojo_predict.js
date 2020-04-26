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
    html += '<div>'
    html += '<table>';
    html += tr2('red',     redBlurb());
    html += tr2('amber', amberBlurb());
    html += tr2('green', greenBlurb());
    html += '</table>';
    html += '</div>';
    const node = $(html);
    setupRagClick(input, node, handler, 'red');
    setupRagClick(input, node, handler, 'amber');
    setupRagClick(input, node, handler, 'green');
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

  const setupRagClick = (input,node,handler,colour) => {
    $(`div#predict-${colour}`,node).click(() => {
      input.val(colour);
      node.remove();
      handler();
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const redBlurb = () => {
    return blurb('some tests will fail');
  };
  const amberBlurb = () => {
    return blurb('the tests wont run yet');
  };
  const greenBlurb = () => {
    return blurb('all the tests will pass');
  };
  const blurb = (s) => {
    return `<div class="predict-blurb">${s}</div>`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const tr2 = (rag, s) => {
    return `<tr><td>${lightImg(rag)}</td><td>${s}</td></tr>`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  const lightImg = (rag) => {
    // kata.scss provides background image with custom :hover
    return `<div class="predict" id="predict-${rag}"></div>`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - -
  return cd;

})(cyberDojo || {}, jQuery);
