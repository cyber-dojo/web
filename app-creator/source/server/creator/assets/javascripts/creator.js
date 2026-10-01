
// A window property, not a bare const: a top-level const lives in the script
// lexical scope, which the pages can see but selenium's evaluate_script cannot.
window.cd = {};

// The URL for a route under wherever this app is mounted. Mirrors path_to()
// in ruby; cd.mountPath is set by layout.erb from SCRIPT_NAME.
cd.mountedPath = (route) => `${cd.mountPath}${route}`;

$.fn.random = function() {
  return this.eq(Math.floor(Math.random() * this.length));
}

// Always-on custom scrollbar: a plain track+thumb wired to a scrollable element.
// The native scrollbar is hidden in CSS; this keeps the thumb sized and
// positioned from the element's scroll state and lets the user drag the thumb or
// click the track. Returns an update() to call whenever the content changes.
cd.wireScrollbar = ($scroll, $track, $thumb) => {
  const scroll = $scroll[0];
  const track = $track[0];
  const thumb = $thumb[0];
  const update = () => {
    const thumbH = scroll.scrollHeight > 0
      ? Math.max(24, Math.round(track.clientHeight * scroll.clientHeight / scroll.scrollHeight))
      : track.clientHeight;
    const maxScroll = scroll.scrollHeight - scroll.clientHeight;
    const maxThumbTop = track.clientHeight - thumbH;
    const top = maxScroll > 0 ? Math.round((scroll.scrollTop / maxScroll) * maxThumbTop) : 0;
    $thumb.css({ height: `${thumbH}px`, top: `${top}px` });
  };
  $scroll.on('scroll', update);
  $(window).on('resize', update);

  let dragging = false, startY = 0, startScroll = 0;
  $thumb.on('mousedown', (event) => {
    dragging = true;
    startY = event.clientY;
    startScroll = scroll.scrollTop;
    $('body').css('user-select', 'none');
    event.preventDefault();
  });
  $(window).on('mousemove', (event) => {
    if (!dragging) { return; }
    const maxScroll = scroll.scrollHeight - scroll.clientHeight;
    const maxThumbTop = track.clientHeight - thumb.offsetHeight;
    const dScroll = maxThumbTop > 0 ? ((event.clientY - startY) / maxThumbTop) * maxScroll : 0;
    scroll.scrollTop = startScroll + dScroll;
  });
  $(window).on('mouseup', () => {
    if (!dragging) { return; }
    dragging = false;
    $('body').css('user-select', '');
  });

  $track.on('mousedown', (event) => {
    if (event.target === thumb) { return; }             // dragging is handled above
    const clickY = event.clientY - track.getBoundingClientRect().top - thumb.offsetHeight / 2;
    const ratio = Math.max(0, Math.min(1, clickY / (track.clientHeight - thumb.offsetHeight)));
    scroll.scrollTop = ratio * (scroll.scrollHeight - scroll.clientHeight);
  });

  return update;
};

cd.setupDisplayNamesClickHandlers = () => {
  const $displayNames = $('.display-name');
  const $displayContent = $('.display-content');
  const $next = $('button.next');

  const showContent = ($element) => {
    const index = $element.data('index');
    $displayContent.val($(`#contents_${index}`).val());
  };

  // The exercise the textarea falls back to when the mouse is not over the
  // names list: the selected exercise once one is clicked, or the random
  // exercise previewed on open until then.
  let $resting;

  const select = ($element) => {
    cd.selectedDisplayName = $element.data('name').trim();
    $displayNames.removeClass('selected');
    $element.addClass('selected');
    $resting = $element;
    showContent($element);
    $next.prop('disabled', false);
  };

  // Hovering an exercise name previews its file content in the textarea,
  // without selecting it; leaving the names list reverts to the resting one.
  $displayNames.mouseenter((event) => {
    $displayNames.removeClass('previewed');
    showContent($(event.currentTarget));
  });
  $('.display-names').mouseleave(() => showContent($resting));

  // Only a click selects an exercise: it turns the name white and enables
  // the next button.
  $displayNames.click((event) => select($(event.currentTarget)));

  const $random = $displayNames.random();
  $random[0].scrollIntoView(); // scrollIntoView is a DOM method, not jQuery
  // The choosers open with next disabled. Preview a random exercise (shown as
  // if the mouse were hovering over it) but leave it unselected, so next stays
  // disabled until the user actually clicks a name.
  $random.addClass('previewed');
  $resting = $random;
  showContent($random);

  // Wire the list's always-on custom scrollbar (its native scrollbar is hidden
  // in CSS). Call the returned update() once to size the thumb, after the random
  // preview has scrolled the list into position.
  const $list = $('.display-names');
  const $listTrack = $list.siblings('.cscroll-track');
  cd.wireScrollbar($list, $listTrack, $listTrack.find('.cscroll-thumb'))();
};

// The group (classroom) choose_ltf page: pick up to 5 language & test-frameworks.
// Hovering a name previews its file content without choosing it. Clicking a name
// in the available list moves it into the chosen list (capped at 5); clicking a
// name in the chosen list moves it back. next is enabled once 1+ are chosen, and
// creates a group from a single choice or a cluster from 2+.
cd.setupGroupLtfChooser = () => {
  const MAX = 5;
  const $available = $('.available-ltfs');
  const $chosen = $('.chosen-ltfs');
  const $displayContent = $('.display-content');
  const $next = $('button.next');

  const $availTrack = $available.siblings('.cscroll-track');
  const updateAvail = cd.wireScrollbar($available, $availTrack, $availTrack.find('.cscroll-thumb'));

  // Each entry keeps its data-index so its file content stays findable in the
  // hidden #contents_<index> textareas after it moves between the lists.
  const byName = (a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase());
  let available = $available.find('.display-name').map(function() {
    return { name: $(this).data('name').trim(), index: $(this).data('index') };
  }).get();
  let chosen = [];

  const showContent = (index) => $displayContent.val($(`#contents_${index}`).val());

  // A row previews its content on hover (never choosing it) and moves lists on
  // click.
  const makeRow = (entry, onClick) => {
    const $row = $('<div>', { 'class': 'display-name' }).text(entry.name);
    $row.mouseenter(() => showContent(entry.index));
    $row.click(onClick);
    return $row;
  };

  const add = (entry) => {
    if (chosen.length >= MAX) { return; }           // cap at MAX
    available = available.filter((e) => e.name !== entry.name);
    chosen.push(entry);
    render();
  };
  const remove = (entry) => {
    chosen = chosen.filter((e) => e.name !== entry.name);
    available.push(entry);
    available.sort(byName);
    render();
  };

  const render = () => {
    $available.empty();
    available.forEach((entry) => $available.append(makeRow(entry, () => add(entry))));

    // Each of the 5 chosen slots keeps its 1..5 number, filled or empty, so the
    // 5-cap always reads. A filled slot is a chosen entry (clicking it moves it
    // back to the available list); an empty slot is a dashed placeholder.
    $chosen.empty();
    for (let slot = 0; slot < MAX; slot++) {
      const $num = $('<span>', { 'class': 'slot-num' }).text(slot + 1);
      if (slot < chosen.length) {
        const entry = chosen[slot];
        const $row = $('<div>', { 'class': 'display-name' })
          .append($num, document.createTextNode(entry.name));
        $row.mouseenter(() => showContent(entry.index));
        $row.click(() => remove(entry));
        $chosen.append($row);
      } else {
        $chosen.append($('<div>', { 'class': 'slot-empty' }).append($num));
      }
    }

    $next.prop('disabled', chosen.length === 0);
    updateAvail();
  };

  render();

  // On open preview a random available entry (shown as if hovered) and scroll it
  // into view, but leave it unchosen so next stays disabled.
  const $rows = $available.find('.display-name');
  if ($rows.length !== 0) {
    const $random = $rows.random();
    const entry = available[$rows.index($random)];
    $random[0].scrollIntoView(); // scrollIntoView is a DOM method, not jQuery
    $random.addClass('previewed');
    showContent(entry.index);
  }

  // A single choice creates a group (as the single-select page does); 2+ create
  // a cluster whose language_names the joiners each pick one of.
  $next.click(() => {
    if (chosen.length === 0) { return; }
    if (chosen.length === 1) {
      const name = encodeURIComponent(chosen[0].name);
      const params = `${cd.urlParams()}&language_name=${name}`;
      $.post(cd.mountedPath('/create.json'),cd.toJSON(params), (response) => cd.goto(response.route));
    } else {
      const body = JSON.stringify({
        type: 'cluster',
        exercise_name: cd.urlParam('exercise_name') || '',
        language_names: chosen.map((e) => e.name)
      });
      $.post(cd.mountedPath('/create.json'),body, (response) => cd.goto(response.route));
    }
  });
};

cd.urlParams = () => {
  const url = window.location.search;
  return url.substring(url.indexOf('?') + 1);
};

cd.urlParam = (name) => {
  const params = new URLSearchParams(window.location.search);
  return params.get(name);
};

cd.goto = (url) => window.location = url;

cd.toJSON = (s) => {                                  // "x=1&y=2&z=3"
  const args = s.split('&');                          // [ "x=1", "y=2", "z=3" ]
  const elements = args.map((arg) => arg.split('=')); // [ ["x","1"],["y","2"],["z","3"]]
  const obj = elements.reduce((m,a) => {
    m[a[0]] = decodeURIComponent(a[1]);
    return m;
  }, {});                            // { "x":"1", "y":"2", "z":"3" }
  return JSON.stringify(obj);        // '{ "x":"1", "y":"2", "z":"3" }'
};

//= = = = = = = = = = = = = = = = = = = = = = = = = = = = =

cd.setupHoverTips = function(nodes) {
  nodes.each(function() {
    const node = $(this);
    const setTipCallBack = () => {
      const tip = node.data('tip');
      cd.showHoverTip(node, tip);
    };
    cd.setTip(node, setTipCallBack);
  });
};

cd.setTip = (node, setTipCallBack) => {
  // The speed of the mouse could easily exceed
  // the speed of any getJSON callback...
  // The mouse-has-left attribute caters for this.
  node.mouseenter(() => {
    node.removeClass('mouse-has-left');
    setTipCallBack(node);
  });
  node.mouseleave(() => {
    node.addClass('mouse-has-left');
    cd.hoverTipContainer().empty();
  });
};

cd.showHoverTip = (node, tip) => {
  if (node.attr('disabled') || node.hasClass('mouse-has-left')) {
    return;
  }
  // Replaces the jQuery UI position() plug-in (https://jqueryui.com/position/)
  // call: { my:'top', at:'bottom', of:node, collision:'fit' }
  // ie place the tip's top-center just below node, kept within the viewport.
  const hoverTip = $('<div>', {
    'class': 'hover-tip'
  }).html(tip);
  // Attach to the DOM first so the tip can be measured.
  cd.hoverTipContainer().html(hoverTip);

  const nodeOffset = node.offset();
  const atCenterX = nodeOffset.left + (node.outerWidth() / 2);
  const belowNodeY = nodeOffset.top + node.outerHeight();
  let left = atCenterX - (hoverTip.outerWidth() / 2); // my:'top' (center horizontally)
  let top = belowNodeY;                               // at:'bottom'

  // collision:'fit' - keep the tip inside the viewport.
  const $window = $(window);
  const minLeft = $window.scrollLeft();
  const minTop = $window.scrollTop();
  const maxLeft = minLeft + $window.width() - hoverTip.outerWidth();
  const maxTop = minTop + $window.height() - hoverTip.outerHeight();
  left = Math.max(minLeft, Math.min(left, maxLeft));
  top = Math.max(minTop, Math.min(top, maxTop));

  hoverTip.css('position', 'absolute').offset({ left: left, top: top });
};

cd.hoverTipContainer = () => {
  return $('#hover-tip-container');
};

cd.setupHomeIcon = () => {
  const $homeIcon = () => $('.home-icon');
  $homeIcon().show().click(() => cd.goto('/'));
  cd.setupHoverTips($homeIcon());
};

cd.windowOpen = (url) => {
  const opened = window.open(url, '_blank');
  if (opened) {
    opened.focus();
  } else {
    alert('Please, allow popups for this website.');
  }
}
