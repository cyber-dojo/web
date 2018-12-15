/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  const options = {
    segmentShowStroke: false,
    segmentStrokeColor: '#757575',
    animationEasing: 'easeOutExpo',
    legend: { display: false }
  };

  cd.pieChart = ($nodes) => {
    $nodes.each((_,node) => {
      const $node = $(node);
      const count = (of) => $node.data(of + '-count');
      const      redCount = count('red');
      const    amberCount = count('amber');
      const    greenCount = count('green');
      const timedOutCount = count('timed-out');

      const data = [
          { value:      redCount, color: '#F00' },
          { value:    amberCount, color: '#FF0' },
          { value:    greenCount, color: '#0F0' },
          { value: timedOutCount, color: 'darkGray' }
      ];

      const ctx = $node[0].getContext('2d');
      const key = $node.data('key');
      const totalCount = redCount + amberCount + greenCount + timedOutCount;
      const animation = ($.data(document.body, key) != totalCount);
      options['animation'] = animation;
      // Chart.js http://www.chartjs.org/docs/
      new Chart(ctx).Pie(data, options);
      $.data(document.body, key, totalCount);
    });
  };

  return cd;

})(cyberDojo || {}, jQuery);
