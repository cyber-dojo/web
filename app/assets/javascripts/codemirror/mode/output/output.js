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

  return {
    token: function(stream, state) {
      if (stream.sol()) {
        if (stream.match(':stdout:')) { return 'variable'; }
        if (stream.match(':stderr:')) { return 'number'; }
        if (stream.match(':status:')) { return 'comment'; }
      }
      stream.skipToEnd();
      return 'null';
    }
  };

});

CodeMirror.defineMIME("text/x-output", "output");

});
