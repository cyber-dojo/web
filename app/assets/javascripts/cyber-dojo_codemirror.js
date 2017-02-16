/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.syntaxHighlightEnabled = false;
  cd.syntaxHighlightTabSize = 4;

  var fileExtension = function (filename) {
    var lastPoint = filename.lastIndexOf('.');
    if (lastPoint == -1) {
      return '';
    }
    return filename.substring(lastPoint);
  };

  var codeMirrorMode = function (filename) {
    filename = filename.toLowerCase();

    switch (filename) {
      case 'makefile':
        return 'text/x-makefile';
      case 'instructions':
        return '';
    }

    switch (fileExtension(filename)) {
      case '.c':
        return 'text/x-csrc';
      case '.cpp':
        return 'text/x-c++src';
      case '.hpp':
      case '.h':
        return 'text/x-c++hdr';
      case '.java':
        return 'text/x-java';
      case '.cs':
        return 'text/x-csharp';
      case '.scala':
        return 'text/x-scala';
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

  var syntaxHighlightFileContentForId = function (filename) {
    return 'syntax_highlight_file_content_for_' + filename;
  };

  var switchEditorToCodeMirror = function (filename) {
    var editor = CodeMirror.fromTextArea(document.getElementById('file_content_for_' + filename), {
      lineNumbers: true,
      matchBrackets: true,
      mode: codeMirrorMode(filename),
      autoRefresh: true,
      indentUnit: cd.syntaxHighlightTabSize,
      tabSize: cd.syntaxHighlightTabSize,
      theme: "default cyber-dojo"
    });

    editor.getWrapperElement().id = syntaxHighlightFileContentForId(filename);

    editor.setOption("extraKeys", {
      'Alt-T': function (cm) {
        $('#test-button').click();
      },
      'Alt-J': function (cm) {
        cd.loadNextFile();
      },
      'Alt-K': function (cm) {
        cd.loadPreviousFile();
      },
      'Alt-O': function (cm) {
        cd.toggleOutputFile();
      }
    });
    var lineNumbers = document.getElementById(filename + '_line_numbers');
    lineNumbers.style.display = 'none';
  };

  var turnSyntaxHighlightOn = function () {
    $.each($('.file_content'), function (i, editor_text_area) {
      var filename = editor_text_area.attributes['data-filename'].value;
      if (filename != 'output') {
        switchEditorToCodeMirror(filename);
      }
    });

    cd.syntaxHighlightEnabled = true;
  };

  var turnSyntaxHighlightOff = function () {
    $.each($('.CodeMirror'), function (i, editor_div) {
      editor_div.CodeMirror.toTextArea();
    });
    $.each($('.line_numbers'), function (i, line_numbers_div) {
      line_numbers_div.style.display = '';
    });

    cd.syntaxHighlightEnabled = false;
  };

  cd.toggleSyntaxHighlight = function () {
    if (cd.syntaxHighlightEnabled) {
      turnSyntaxHighlightOff();
    }
    else {
      turnSyntaxHighlightOn();
    }
  };

  cd.removeSyntaxHilightEditor = function (filename) {
    var element = document.getElementById(syntaxHighlightFileContentForId(filename));
    if (element != null) {
      element.CodeMirror.toTextArea();
    }
  };

  cd.focusSyntaxHighlightEditor = function (filename) {
    var element = document.getElementById(syntaxHighlightFileContentForId(filename));
    if (element != null) {
      element.CodeMirror.focus();
    }
  };

  cd.switchEditorIfSyntaxHighlightEnabled = function (filename) {
    if (cd.syntaxHighlightEnabled) {
      switchEditorToCodeMirror(filename);
    }
  };

  cd.saveCodeFromSyntaxHighlightEditors = function () {
    $.each($('.CodeMirror'), function (i, editor_div) {
      editor_div.CodeMirror.save();
    });
  };

  return cd;

})(cyberDojo || {}, jQuery);
