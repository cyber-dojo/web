// CodeMirror, copyright (c) by Marijn Haverbeke and others
// Distributed under an MIT license: http://codemirror.net/LICENSE

(function(mod) {
  if (typeof exports == "object" && typeof module == "object") // CommonJS
    mod(require("../../lib/codemirror"));
  else if (typeof define == "function" && define.amd) // AMD
    define(["../../lib/codemirror"], mod);
  else // Plain browser env
    mod(CodeMirror);
})(function(CodeMirror) {
"use strict";

CodeMirror.defineMode("output", function(config) {
  var sss = null;
  return {
    token: function(stream, state) {
      if (stream.sol()) { /* sol==start-of-line */
        if (stream.match(':stdout:')) { return sss = 'variable'; } // blue
        if (stream.match(':stderr:')) { return sss = 'number'; }   // red
        if (stream.match(':status:')) { return sss = 'comment'; }  // grey
      }
      stream.skipToEnd();
      return sss;
    }
  };

});

CodeMirror.defineMIME("text/x-output", "output");

});
