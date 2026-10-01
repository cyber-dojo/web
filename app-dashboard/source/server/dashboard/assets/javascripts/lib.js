'use strict';
(() => {

  cd.lib = {};

  // Every cd fetch asks for JSON and identifies itself as an XHR, so the app
  // can tell these apart from a page navigation.
  cd.lib.jsonHeaders = {
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  };

  // The URL for a route under wherever this app is mounted. Mirrors path_to()
  // in ruby; cd.mountPath is set by layout.erb from SCRIPT_NAME.
  cd.mountedPath = (route) => `${cd.mountPath}${route}`;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Older katas did not distinguish between
  //   - an auto-revert, from an incorrect test prediction
  //   - a [checkout], from the review page.
  // Both were light.revert == [id,index]

  cd.lib.hasPrediction = (light) => light.predicted != undefined && light.predicted != 'none';
  cd.lib.isRevert = (light) => light.revert != undefined;
  cd.lib.isCheckout = (light) => light.checkout != undefined;

  cd.lib.isTestFile = (filename) => {
    // True if the stem starts or ends with a test word (tests/test/spec/steps).
    // Middle-only matches (eg my_test_helper) do not count.
    const testWords = ['tests', 'test', 'spec', 'steps'];
    const ext = filename.lastIndexOf('.');
    const hi = (ext !== -1) ? ext : filename.length;
    const stem = filename.substring(0, hi).toLowerCase();
    const base = stem.substring(stem.lastIndexOf('/') + 1);
    return testWords.some(word => base.startsWith(word) || base.endsWith(word));
  };

})();
