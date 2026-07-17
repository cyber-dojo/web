/*global cyberDojo*/
'use strict';
var cyberDojo = ((cd) => {

  // The stale-tab predicate (docs/mobbing-stale-tab-lock.md): true iff some event
  // past my knownHead was written by a different tab than mine. My own writes
  // (whose tab_id matches myTabId) never make me stale, so knownHead stays the
  // load head - it never needs advancing.
  cd.isStale = (events, knownHead, myTabId) => {
    return events.some((event) => event.index > knownHead && tabIdOf(event) !== myTabId);
  };

  // The tab_id half of a committed event's stored id: the characters after the
  // 32-char laptop_id half (see the doc's laptop_id + tab_id split). Null-safe: a
  // legacy/malformed event with no laptop_id yields '', which never matches a live
  // tab_id, so it reads as not-mine (stale) rather than throwing.
  const tabIdOf = (event) => (event.laptop_id || '').slice(32);

  // The laptop_id half of a committed event's stored id: the first 32 chars.
  // Null-safe for the same reason as tabIdOf.
  const laptopIdOf = (event) => (event.laptop_id || '').slice(0, 32);

  // Whether an event carries a stored id long enough to classify by (laptopHalf +
  // tabId). A missing/short id (legacy or malformed writer) cannot be classified.
  const hasStoredId = (event) => typeof event.laptop_id === 'string' && event.laptop_id.length >= 64;

  // This tab's laptop half, rendered by web in a <meta name="laptop-id"> tag.
  const myLaptopId = () => document.querySelector('meta[name=laptop-id]').getAttribute('content');

  // Classify why this tab is stale, from the not-mine events above knownHead, to
  // choose the presentation: 'laptop' (a different laptop half - a real mobbing
  // collision - overlay), 'generic' (a not-mine event we cannot classify because
  // it has no stored id - app-bar generic message), else 'tab' (another tab of
  // this browser - app-bar message). 'laptop' wins over 'generic' as the definite,
  // stronger signal.
  const staleKind = (events, knownHead, myTabId) => {
    const notMine = events.filter((event) => event.index > knownHead && tabIdOf(event) !== myTabId);
    if (notMine.some((event) => hasStoredId(event) && laptopIdOf(event) !== myLaptopId())) {
      return 'laptop';
    }
    else if (notMine.some((event) => !hasStoredId(event))) {
      return 'generic';
    }
    else {
      return 'tab';
    }
  };

  // A fresh random 32-hex id for this tab (this browsing context), generated
  // once when the page loads and held for the tab's life.
  const generateTabId = () => {
    const bytes = crypto.getRandomValues(new Uint8Array(16));
    return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
  };

  // Show a short stale-tab reminder in the app-bar. Used directly for the
  // unintrusive another-tab case, and again when the another-laptop overlay is
  // dismissed, so a persistent note remains after the overlay is gone.
  const showAppBarReminder = (text) => {
    const message = document.createElement('span');
    message.id = 'mobbing-app-bar-message';
    message.textContent = text;
    document.getElementById('app-bar').appendChild(message);
  };

  // Another laptop committed above knownHead - a real mobbing collision. Cover the
  // page with a dimmed lock overlay. A full-page overlay (not a modal) makes clear
  // this is the page going stale, not a result of a [test] the user may have just
  // pressed. First close any open #run-tests-info dialog: it renders in the browser
  // top layer, above the overlay, so it must go. The single Dismiss button removes
  // the overlay so the user can reach and copy their still-visible read-only edits,
  // leaving the app-bar reminder behind; the page stays locked. Clearing the lock
  // is a browser refresh (deliberately the user's own action, not a button here).
  const showMobbingOverlay = () => {
    const dialog = document.getElementById('run-tests-info');
    if (dialog && dialog.open) {
      dialog.close();
    }
    const overlay = document.createElement('div');
    overlay.id = 'mobbing-overlay';

    const box = document.createElement('div');
    box.id = 'mobbing-overlay-box';

    const message = document.createElement('div');
    message.id = 'mobbing-overlay-message';
    message.textContent = [
      'This kata was changed on another laptop.',
      'You are out of sync with the latest version.',
    ].join("\n");

    const warning = document.createElement('div');
    warning.id = 'mobbing-overlay-warning';
    warning.textContent =
      'Once dismissed you will be locked in read-only mode. Refresh will clear the ' +
      'lock and resync, which may lose recent edits to the current file.';

    const dismiss = document.createElement('button');
    dismiss.id = 'mobbing-overlay-dismiss';
    dismiss.type = 'button';
    dismiss.textContent = 'Dismiss';
    dismiss.addEventListener('click', () => {
      overlay.remove();
      showAppBarReminder('This kata was changed on another laptop. Refresh to continue.');
    });

    box.appendChild(message);
    box.appendChild(warning);
    box.appendChild(dismiss);
    overlay.appendChild(box);
    document.body.appendChild(overlay);
  };

  // Lock this tab: another tab or laptop has committed above knownHead, so this
  // tab is out of date. Set the locked flag (checked by cd.revertOrCheckout),
  // mark the page stale, disable every control marked `.lockable` (the [test],
  // predict, checkout, revert and fork buttons, plus the predict and auto-revert
  // checkboxes), make the editors read-only, and stop the predict/auto-revert
  // hover-tips (clearing any tip showing at this instant), so it cannot commit or
  // edit from a stale state. Refresh clears it. The caller then shows the message
  // (overlay for another laptop, app-bar reminder for another tab); the overlay's
  // Dismiss lets the user copy edits first while the page stays locked.
  const lock = () => {
    cd.mobbingPoll.locked = true;
    document.body.classList.add('mobbing-stale');
    document.querySelectorAll('.lockable').forEach((control) => control.disabled = true);
    cd.setFilesEditable(false);
    cd.disableFileButtons();
    cd.disableTips('#predict-checkbox-cell, #revert-title-cell');
    cd.removeTip();
  };

  // The stale-tab poll (docs/mobbing-stale-tab-lock.md). tabId identifies this
  // tab's own writes; knownHead is the committed head index at load (seeded by
  // edit.erb) and stays fixed for the tab's life. enable() checks the committed
  // stream every intervalMs; check() runs one such check and locks the tab the
  // first time isStale is true. A rejected [test] write also calls check() so it
  // locks at once rather than waiting for the next interval. check() backs off
  // while the tab is hidden; a visibilitychange re-checks on foreground, and the
  // poll stops on page unload (see the listeners below).
  cd.mobbingPoll = {
    tabId: generateTabId(),
    knownHead: undefined,
    intervalMs: 5000,
    interval: undefined,
    locked: false,
    polling: false,

    // Read the committed stream once and, if this tab is now stale, lock it and
    // show the message (full-page overlay for another laptop, app-bar reminder for
    // another tab). A no-op once already locked, so repeated calls (interval +
    // [test] catch) are safe.
    check: function() {
      if (this.locked || document.hidden) {
        return;   // a hidden tab backs off; visibilitychange re-checks on foreground
      }
      cd.lib.getEvents(cd.kata.id, (events) => {
        if (!Array.isArray(events)) {
          return;   // an empty/malformed read must never lock; retry next tick
        }
        if (cd.isStale(events, this.knownHead, this.tabId)) {
          this.stop();
          lock();
          const kind = staleKind(events, this.knownHead, this.tabId);
          if (kind === 'laptop') {
            showMobbingOverlay();
          }
          else if (kind === 'generic') {
            showAppBarReminder('This kata changed. Refresh to continue.');
          }
          else {
            showAppBarReminder('This kata was changed in another tab. Refresh to continue.');
          }
        }
      }).catch(() => {});   // a failed read (offline / 5xx / bad body) never locks
    },

    enable: function() {
      this.stop();   // clear any previous interval so re-enabling runs one timer
      this.polling = true;
      this.interval = setInterval(() => this.check(), this.intervalMs);
    },

    stop: function() {
      clearInterval(this.interval);
      this.polling = false;
    }
  };

  // Evaluate immediately when the tab is brought to the foreground: a tab that
  // went stale while hidden (its interval ticks were no-ops) locks at once rather
  // than waiting for the next tick. Guarded by `polling` so it never fires a read
  // on a page where the poll was not enabled.
  document.addEventListener('visibilitychange', () => {
    if (cd.mobbingPoll.polling && !document.hidden) {
      cd.mobbingPoll.check();
    }
  });

  // Stop the poll as the page goes away, so no stray read runs during unload.
  window.addEventListener('pagehide', () => cd.mobbingPoll.stop());

  return cd;

})(cyberDojo || {});
