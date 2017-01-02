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

    switch(fileExtension(filename))
    {
      case '.sh':
        return 'text/x-sh';
      case '.cpp':
      case '.hpp':
      case '.c':
      case '.h':
        return 'text/x-c++src';
    }
    return '';
  };

  return cd;

})(cyberDojo || {}, jQuery);
