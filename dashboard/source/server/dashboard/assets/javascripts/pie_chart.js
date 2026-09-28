'use strict';
(() => {

  /**
   * Renders a RAG traffic-light pie chart into each canvas node and wires up
   * a hover tip showing the red/amber/green counts.
   * Animates only when the traffic-light counts have changed since the last
   * render, so auto-refresh does not continuously animate unchanged charts.
   */
  cd.pieChart = ($nodes) => {
    $nodes.each((_,node) => {
      const $node = $(node);
      const count = (of) => $node.data(of + '-count');
      const      redCount = count('red');
      const    amberCount = count('amber');
      const    greenCount = count('green');
      const timedOutCount = count('timed-out');
      const   totalCount  = redCount + amberCount + greenCount + timedOutCount;

      const key = $node.data('key');
      // Only animate when the data has changed since the last render.
      const animate = ($.data(document.body, key) !== totalCount);
      $.data(document.body, key, totalCount);

      const ctx = $node[0].getContext('2d');
      // S1848 suppressed: Chart.js renders into ctx as a constructor side-effect; no reference needed.
      new Chart(ctx, { // NOSONAR javascript:S1848
        type: 'pie',
        data: {
          datasets: [{
            data: [redCount, amberCount, greenCount, timedOutCount],
            backgroundColor: ['#F00', '#FF0', '#0F0', 'darkGray'],
            borderWidth: 0
          }]
        },
        options: {
          responsive: false,
          events: [],
          animation: animate && { easing: 'easeOutExpo' },
          plugins: {
            legend:  { display: false },
            tooltip: { enabled: false }
          }
        }
      });

      cd.setupTrafficLightCountHoverTip($node.parent(), {
        red:       redCount,
        amber:     amberCount,
        green:     greenCount,
        timed_out: timedOutCount
      });
    });
  };

})();
