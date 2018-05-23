/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.pieChart = function(nodes) {
    // Chart.js http://www.chartjs.org/docs/
    const options = {
      segmentShowStroke : false,
      segmentStrokeColor : '#757575',
      animationEasing : 'easeOutExpo'
    };
    nodes.each(function() {
      const node = $(this);
      const count = function(of) { return node.data(of + '-count'); };
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

      const ctx = node[0].getContext('2d');
      const key = node.data('key');
      const totalCount = redCount + amberCount + greenCount + timedOutCount;
      const animation = ($.data(document.body, key) != totalCount);
      options['animation'] = animation;
      new Chart(ctx).Pie(data, options);
      $.data(document.body, key, totalCount);
    });
  };

  return cd;

})(cyberDojo || {}, jQuery);
