
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

// The setup page: choose language & test-framework(s) and an exercise on one
// page. type is 'kata' (solo: one LTF, may skip the exercise) or 'group' (up to
// 5 LTFs, must choose an exercise). The action button creates the practice: one
// LTF posts type with exercise_name and language_name; 2+ post a cluster.
cd.setupChooser = (type) => {
  const maxLtfs = type === 'group' ? 5 : 1;
  const $page = $('#setup-page');
  const $preview = $page.find('.display-content');
  const $next = $page.find('button.next');
  const $skip = $page.find('label.skip input');
  const $languages = $page.find('.languages');
  const $frameworks = $page.find('.frameworks');
  const $exercises = $page.find('.exercises');
  const languageNote =
    'The starting files for any language/test-framework are always a function ' +
    'that returns 6*9 and a test that expects 42. These starting files are simply ' +
    'to help you get started and are _unrelated_ to the chosen exercise.';

  // Returns { name: preview } for the hidden textareas carrying attr.
  const previewsFrom = (attr) => {
    const previews = {};
    $(`textarea[${attr}]`).each(function() {
      previews[$(this).attr(attr)] = $(this).val();
    });
    return previews;
  };
  const exercisePreviews = previewsFrom('data-exercise-name');
  const ltfPreviews = previewsFrom('data-ltf-name');
  const ltfNames = Object.keys(ltfPreviews);

  // Returns [language, framework], splitting an LTF name on its FIRST comma.
  const split = (name) => {
    const at = name.indexOf(',');
    return at === -1 ? [name, ''] : [name.slice(0, at), name.slice(at + 1).trim()];
  };
  // Returns the frameworks offered for language, in names order.
  const frameworksOf = (language) =>
    ltfNames.filter((name) => split(name)[0] === language).map((name) => split(name)[1]);

  let exerciseChoice = null;   // an exercise name, '' for skip, null for none yet
  let currentLanguage = null;  // the language whose frameworks are listed
  let currentFramework = null; // the framework chosen since that language was
  let chosenLtfs = [];         // full LTF names
  let restingPreview = '';     // what the preview shows when nothing is hovered

  const show = (text) => $preview.val(text);
  const rest = () => show(restingPreview);

  // Returns a list row showing text, previewing preview() on hover.
  const makeRow = (text, preview, onClick) => {
    const $row = $('<div>', { 'class': 'display-name' }).text(text);
    $row.mouseenter(() => show(preview()));
    $row.click(onClick);
    return $row;
  };

  // Returns the gutter checkbox for a chosen slot: ticked when chosen, and
  // unticking it calls unchoose. Only choosing from a column ticks it, so
  // ticking an unchosen one directly does nothing.
  const choiceBox = (chosen, unchoose) => {
    const $box = $('<input>', { type: 'checkbox' }).prop('checked', chosen);
    $box.click((event) => event.stopPropagation());
    $box.change(() => {
      if (chosen) {
        unchoose();
      }
      else {
        $box.prop('checked', false);
      }
    });
    return $box;
  };

  // Returns a chosen slot: the named row, or a dashed placeholder when text is
  // null, with gutter (a number and/or checkbox) hanging to its left.
  const makeSlot = (text, gutter, preview, onClick) => {
    const $slot = text === null
      ? $('<div>', { 'class': 'slot-empty' })
      : makeRow(text, preview, onClick).addClass('filled');
    return $slot.prepend($('<span>', { 'class': 'slot-num' }).append(gutter));
  };

  const chooseLtf = (name) => {
    if (chosenLtfs.includes(name)) {
      return;
    }
    if (maxLtfs === 1) {
      chosenLtfs = [name];
    }
    else if (chosenLtfs.length < maxLtfs) {
      chosenLtfs.push(name);
    }
    else {
      return;
    }
    currentFramework = split(name)[1];
    restingPreview = ltfPreviews[name];
    render();
  };

  const renderFrameworks = () => {
    $frameworks.empty();
    frameworksOf(currentLanguage).forEach((framework) => {
      const name = `${currentLanguage}, ${framework}`;
      const $row = makeRow(framework, () => ltfPreviews[name], () => chooseLtf(name));
      $row.toggleClass('selected', framework === currentFramework);
      $frameworks.append($row);
    });
  };

  const renderChosen = () => {
    const unchooseExercise = () => {
      exerciseChoice = null;
      restingPreview = '';
      render();
    };
    const exerciseChosen = exerciseChoice !== null && exerciseChoice !== '';
    $page.find('.exercise-chosen').empty().append(makeSlot(
      exerciseChosen ? exerciseChoice : null,
      choiceBox(exerciseChosen, unchooseExercise),
      () => exercisePreviews[exerciseChoice],
      unchooseExercise));

    const $ltfs = $page.find('.ltfs-chosen').empty();
    for (let i = 0; i < maxLtfs; i++) {
      const name = chosenLtfs[i];
      const unchooseLtf = () => {
        chosenLtfs = chosenLtfs.filter((n) => n !== name);
        if (name === `${currentLanguage}, ${currentFramework}`) {
          currentFramework = null;
        }
        render();
      };
      const gutter = [choiceBox(name !== undefined, unchooseLtf)];
      if (maxLtfs > 1) {
        gutter.unshift(`${i + 1} `);
      }
      $ltfs.append(makeSlot(name === undefined ? null : name, gutter,
                            () => ltfPreviews[name], unchooseLtf));
    }
  };

  const updateScrollbars = [$languages, $exercises].map(($list) => {
    const $track = $list.siblings('.cscroll-track');
    return cd.wireScrollbar($list, $track, $track.find('.cscroll-thumb'));
  });

  const render = () => {
    $exercises.find('.display-name').each(function() {
      $(this).toggleClass('selected', $(this).attr('data-name') === exerciseChoice);
    });
    $languages.find('.display-name').each(function() {
      $(this).toggleClass('current', $(this).attr('data-name') === currentLanguage);
    });
    renderFrameworks();
    renderChosen();
    $skip.prop('checked', exerciseChoice === '');
    $next.prop('disabled', !(exerciseChoice !== null && chosenLtfs.length > 0));
    rest();
    updateScrollbars.forEach((update) => update());
  };

  $exercises.find('.display-name').each(function() {
    const name = $(this).attr('data-name');
    $(this).mouseenter(() => show(exercisePreviews[name]));
    $(this).click(() => {
      exerciseChoice = name;
      restingPreview = exercisePreviews[name];
      render();
    });
  });
  $languages.find('.display-name').each(function() {
    const language = $(this).attr('data-name');
    $(this).mouseenter(() => show(languageNote));
    $(this).click(() => {
      currentLanguage = language;
      currentFramework = null;
      render();
    });
  });
  $page.find('.display-names, .chosen').mouseleave(rest);

  // Ticking skip is the explicit choice of no exercise; unticking it leaves the
  // exercise unchosen again.
  $skip.change(() => {
    exerciseChoice = $skip.prop('checked') ? '' : null;
    restingPreview = '';
    render();
  });

  $page.find('button.switch').click(() =>
    cd.goto(cd.mountedPath(`/choose_custom_problem?type=${type}`)));

  $next.click(() => {
    const body = chosenLtfs.length === 1
      ? { type: type, exercise_name: exerciseChoice, language_name: chosenLtfs[0] }
      : { type: 'cluster', exercise_name: exerciseChoice, language_names: chosenLtfs };
    $.post(cd.mountedPath('/create.json'), JSON.stringify(body), (response) => cd.goto(response.route));
  });

  // Open on a random exercise preview (unchosen) and a random current language,
  // so the test-framework column is never empty; scroll each into view.
  const $randomExercise = $exercises.find('.display-name').random();
  restingPreview = exercisePreviews[$randomExercise.attr('data-name')];
  const $randomLanguage = $languages.find('.display-name').random();
  currentLanguage = $randomLanguage.attr('data-name');
  render();
  [[$exercises, $randomExercise], [$languages, $randomLanguage]].forEach(([$list, $row]) => {
    $list.scrollTop($row[0].offsetTop - ($list[0].clientHeight - $row[0].offsetHeight) / 2);
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
