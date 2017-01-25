/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.syntaxHighlightEnabled = false;
  cd.syntaxHighlightTabSize = 4;

  var fileExtension = function(filename) {
    var lastPoint = filename.lastIndexOf('.');
    if(lastPoint == -1) {
      return '';
    }
    return filename.substring(lastPoint);
  };

  var codeMirrorMode = function(filename) {
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

  var switchEditorToCodeMirror = function(filename) {
    var editor = CodeMirror.fromTextArea(document.getElementById('file_content_for_' + filename),  {
        lineNumbers: true,
        matchBrackets: true,
        mode: codeMirrorMode(filename),
        autoRefresh: true,
        indentUnit: cd.syntaxHighlightTabSize,
        tabSize: cd.syntaxHighlightTabSize,
        theme: "default cyber-dojo"
    });

    editor.setOption("extraKeys", {
        'Alt-T': function(cm) {
            $('#test-button').click();
        },
        'Alt-J': function(cm) {
            cd.loadNextFile();
        },
        'Alt-K': function(cm) {
            cd.loadPreviousFile();
        },
        'Alt-O': function(cm) {
            cd.toggleOutputFile();
        }
    });
    var lineNumbers = document.getElementById(filename + '_line_numbers');
    lineNumbers.style.display = 'none';
  };

  cd.switchEditorIfSyntaxHighlightEnabled = function(filename) {
      if(cd.syntaxHighlightEnabled) {
          switchEditorToCodeMirror(filename);
      }
  };

  var turnSyntaxHighlightOn = function() {
      $.each($('.file_content'), function(i, editor_text_area) {
          switchEditorToCodeMirror(editor_text_area.attributes['data-filename'].value);
      });

      cd.syntaxHighlightEnabled = true;
  };

  var turnSyntaxHighlightOff = function() {
      $.each($('.CodeMirror'), function(i, editor_div) {
          editor_div.CodeMirror.toTextArea();
      });
      $.each($('.line_numbers'), function(i, line_numbers_div) {
          line_numbers_div.style.display = '';
      });

      cd.syntaxHighlightEnabled = false;
  };

  cd.toggleSyntaxHighlight = function() {
      if(cd.syntaxHighlightEnabled) {
          turnSyntaxHighlightOff();
      }
      else {
          turnSyntaxHighlightOn();
      }
  };

  return cd;

})(cyberDojo || {}, jQuery);
