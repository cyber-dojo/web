/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  var fileExtension = function(filename) {
    var lastPoint = filename.lastIndexOf('.');
    if(lastPoint == -1) {
      return '';
    }
    return filename.substring(lastPoint);
  };

  cd.codeMirrorMode = function(filename) {
    switch(filename) {
      case 'makefile':
        return 'text/x-makefile';
      case 'instructions':
        return '';
    }

    switch(fileExtension(filename)) {
      case '.cpp':
      case '.hpp':
      case '.c':
      case '.h':
        return 'text/x-c++src';
      case '.clj':
        return 'text/x-clojure';
      case '.coffee':
        return 'text/x-coffeescript';
      case '.d':
        return 'text/x-d';
      case '.feature':
        return 'text/x-feature';
      case '.js':
        return 'text/javascript';
      case '.php':
        return 'text/x-php';
      case '.py':
        return 'text/x-python';
      case '.rb':
        return 'text/x-ruby';
      case '.sh':
        return 'text/x-sh';
      case '.vb':
        return 'text/x-vb';
      case '.vhdl':
        return 'text/x-vhdl';
    }
    return '';
  };

  return cd;

})(cyberDojo || {}, jQuery);
