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
  // 32-char laptop_id half (see the doc's laptop_id + tab_id split).
  const tabIdOf = (event) => event.laptop_id.slice(32);

  // The laptop_id half of a committed event's stored id: the first 32 chars.
  const laptopIdOf = (event) => event.laptop_id.slice(0, 32);

  // This tab's laptop half, rendered by web in a <meta name="laptop-id"> tag.
  const myLaptopId = () => document.querySelector('meta[name=laptop-id]').getAttribute('content');

  // Word the refresh banner from the events above knownHead that are not mine:
  // "another laptop" if any has a different laptop half, else "another tab".
  const bannerMessage = (events, knownHead, myTabId) => {
    const notMine = events.filter((event) => event.index > knownHead && tabIdOf(event) !== myTabId);
    if (notMine.some((event) => laptopIdOf(event) !== myLaptopId())) {
      return 'This kata was changed on another laptop. Refresh to continue.';
    }
    return 'This kata was changed in another tab. Refresh to continue.';
  };

  // A fresh random 32-hex id for this tab (this browsing context), generated
  // once when the page loads and held for the tab's life.
  const generateTabId = () => {
    const bytes = crypto.getRandomValues(new Uint8Array(16));
    return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
  };

  // Show a banner telling the user this tab is out of date and must be refreshed.
  const showBanner = (message) => {
    const banner = document.createElement('div');
    banner.id = 'mobbing-banner';
    banner.textContent = message;
    document.body.appendChild(banner);
  };

  // Lock this tab: another tab or laptop has committed above knownHead, so this
  // tab is out of date. Set the locked flag (checked by cd.revertOrCheckout),
  // mark the page stale, disable the [test], file, checkout, revert and fork
  // buttons, make the editors read-only, and show the refresh banner, so it
  // cannot commit or edit from a stale state. Refresh is the only exit.
  const lock = (message) => {
    cd.mobbingPoll.locked = true;
    document.body.classList.add('mobbing-stale');
    document.getElementById('test-button').disabled = true;
    document.getElementById('checkout-button').disabled = true;
    document.getElementById('revert-button').disabled = true;
    document.getElementById('fork-button').disabled = true;
    cd.setFilesEditable(false);
    cd.disableFileButtons();
    showBanner(message);
  };

  // The stale-tab poll (docs/mobbing-stale-tab-lock.md). tabId identifies this
  // tab's own writes; knownHead is the committed head index at load (seeded by
  // edit.erb) and stays fixed for the tab's life. enable(id) polls the committed
  // stream every intervalMs and locks the tab the first time isStale is true.
  cd.mobbingPoll = {
    tabId: generateTabId(),
    knownHead: undefined,
    intervalMs: 5000,
    locked: false,
    polling: false,

    enable: function(id) {
      this.polling = true;
      const poll = setInterval(() => {
        cd.lib.getEvents(id, (events) => {
          if (cd.isStale(events, this.knownHead, this.tabId)) {
            clearInterval(poll);
            lock(bannerMessage(events, this.knownHead, this.tabId));
          }
        });
      }, this.intervalMs);
    }
  };

  return cd;

})(cyberDojo || {});
