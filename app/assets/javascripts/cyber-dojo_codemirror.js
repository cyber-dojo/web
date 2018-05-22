/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  const plainTheme = 'cyber-dojo-default';
  const colourTheme = 'cyber-dojo-colour';
  const noLineNumbersTheme = ' cyber-dojo-no-linenumbers';

  var fileExtension = function(filename) {
    var lastPoint = filename.lastIndexOf('.');
    if (lastPoint == -1) {
      return '';
    }
    return filename.substring(lastPoint);
  };

  var codeMirrorMode = function(filename) {
    filename = filename.toLowerCase();

    switch (filename) {
      case 'makefile':
        return 'text/x-makefile';
      case 'instructions':
      case 'output':
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
      case '.html':
      case '.htm':
        return 'text/html';
      case '.xml':
        return 'text/xml';
      case '.md':
        return 'text/x-markdown';
      case '.go':
        return 'text/x-go';
      case '.groovy':
        return 'text/x-groovy';
      case '.hs':
        return 'text/x-haskell';
      case '.swift':
        return 'text/x-swift';
    }
    return '';
  };

  var codeMirrorIndentWithTabs = function(filename) {
    filename = filename.toLowerCase();
    switch (filename) {
      case 'makefile':
        return true;
      default:
        return false;
    }
  };

  var syntaxHighlightFileContentForId = function(filename) {
    return 'syntax_highlight_file_content_for_' + filename;
  };

  var runActionOnAllCodeMirrorEditors = function(action) {
    $.each($('.CodeMirror'), function (i, editor_div) {
      action(editor_div.CodeMirror);
    });
  };

  //================================================================

  var syntaxHighlightEnabled = function() {
    var enabled = false;

    runActionOnAllCodeMirrorEditors(function(editor) {
      var theme = editor.getOption('theme');

      if (theme.indexOf(colourTheme) !== -1) {
        enabled = true;
      }
    });

    return enabled;
  };

  var enableSyntaxHighlight = function(editor) {
    var theme = editor.getOption('theme');
    theme = theme.replace(noLineNumbersTheme, '');
    editor.setOption('theme', colourTheme);
    editor.setOption('smartIndent', true);
  };

  var disableSyntaxHighlight = function(editor) {
    var theme = editor.getOption('theme');
    theme += noLineNumbersTheme;
    editor.setOption('theme', plainTheme);
    editor.setOption('smartIndent', false);
  };

  cd.toggleSyntaxHighlight = function() {
    if(syntaxHighlightEnabled()) {
      runActionOnAllCodeMirrorEditors(disableSyntaxHighlight);
    } else {
      runActionOnAllCodeMirrorEditors(enableSyntaxHighlight);
    }
  };

  //================================================================

  var areLineNumbersVisible = function() {
    var enabled = true;

    runActionOnAllCodeMirrorEditors(function(editor) {
      var theme = editor.getOption('theme');

      if (theme.indexOf(noLineNumbersTheme) !== -1) {
        enabled = false;
      }
    });

    return enabled;
  };

  var showLineNumbersForEditor = function(editor) {
    var theme = editor.getOption('theme');
    theme = theme.replace(noLineNumbersTheme, '');
    editor.setOption('theme', theme);
  };

  var hideLineNumbersForEditor = function(editor) {
    var theme = editor.getOption('theme');
    theme += noLineNumbersTheme;
    editor.setOption('theme', theme);
  };

  var toggleLineNumbers = function(cm, lineNumber) {
    if(areLineNumbersVisible()) {
      runActionOnAllCodeMirrorEditors(hideLineNumbersForEditor);
    } else {
      runActionOnAllCodeMirrorEditors(showLineNumbersForEditor);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.switchEditorToCodeMirror = function(filename) {
    var textArea = document.getElementById('file_content_for_' + filename);
    var parent = textArea.parentNode;

    textArea.style.display = 'none';

    var editor = CodeMirror(parent, {
      lineNumbers: true,
      matchBrackets: true,
      mode: codeMirrorMode(filename),
      indentUnit: cd.syntaxHighlightTabSize,
      tabSize: cd.syntaxHighlightTabSize,
      indentWithTabs: codeMirrorIndentWithTabs(filename),
      theme: plainTheme,
      readOnly: (filename == 'output'),
      smartIndent: false
    });

    editor.cyberDojoTextArea = textArea;
    editor.setValue(textArea.value);

    if(!areLineNumbersVisible()) {
      hideLineNumbersForEditor(editor);
    }

    editor.on('gutterClick', toggleLineNumbers);

    editor.getWrapperElement().id = syntaxHighlightFileContentForId(filename);

    editor.setOption('extraKeys', {
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

    if(!codeMirrorIndentWithTabs(filename)) {
      editor.addKeyMap({
        Tab: function (cm) {
          if (cm.somethingSelected()) {
            cm.indentSelection('add');
          }
          else {
            cm.execCommand('insertSoftTab');
          }
        }
      }, true);
    }

    var lineNumbers = document.getElementById(filename + '_line_numbers');
    lineNumbers.style.display = 'none';
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.switchAllEditorsToCodeMirror = function() {
    $.each($('.file_content'), function (i, editor_text_area) {
      var filename = editor_text_area.attributes['data-filename'].value;
      cd.switchEditorToCodeMirror(filename);
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.focusSyntaxHighlightEditor = function(filename) {
    var element = document.getElementById(syntaxHighlightFileContentForId(filename));
    if (element != null) {
      element.CodeMirror.refresh();
      element.CodeMirror.focus();
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.saveCodeFromSyntaxHighlightEditors = function() {
    $.each($('.CodeMirror'), function (i, editor_div) {
      editor_div.CodeMirror.cyberDojoTextArea.value = editor_div.CodeMirror.getValue();
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.saveCodeFromIndividualSyntaxHighlightEditor = function(filename) {
    var editor_div = document.getElementById(syntaxHighlightFileContentForId(filename));
    editor_div.CodeMirror.cyberDojoTextArea.value = editor_div.CodeMirror.getValue();
  };

  return cd;

})(cyberDojo || {}, jQuery);
