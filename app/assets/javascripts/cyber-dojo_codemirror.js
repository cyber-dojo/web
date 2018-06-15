/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.toggleSyntaxHighlight = () => {
    if (syntaxHighlightEnabled()) {
      runActionOnAllCodeMirrorEditors(disableSyntaxHighlight);
    } else {
      runActionOnAllCodeMirrorEditors(enableSyntaxHighlight);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.toggleLineNumbers = () => {
    if (lineNumbersAreVisible()) {
      runActionOnAllCodeMirrorEditors(hideLineNumbersForEditor);
    } else {
      runActionOnAllCodeMirrorEditors(showLineNumbersForEditor);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.switchEditorToCodeMirror = (filename) => {
    const textArea = document.getElementById('file_content_for_' + filename);
    const parent = textArea.parentNode;
    const editor = CodeMirror(parent, editorOptions(filename));

    textArea.style.display = 'none';
    editor.cyberDojoTextArea = textArea;
    editor.setValue(textArea.value);

    if (!lineNumbersAreVisible()) {
      hideLineNumbersForEditor(editor);
    }

    editor.getWrapperElement().id = syntaxHighlightFileContentForId(filename);
    bindHotKeys(editor);

    if (!codeMirrorIndentWithTabs(filename)) {
      editor.addKeyMap({
        Tab: (cm) => {
          if (cm.somethingSelected()) {
            cm.indentSelection('add');
          } else {
            cm.execCommand('insertSoftTab');
          }
        }
      }, true);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.focusSyntaxHighlightEditor = (filename) => {
    const element = document.getElementById(syntaxHighlightFileContentForId(filename));
    if (element != null) {
      element.CodeMirror.refresh();
      element.CodeMirror.focus();
    }
    if (syntaxHighlightEnabled()) {
      enableSyntaxHighlight(element.CodeMirror);
    }
    if (!lineNumbersAreVisible()) {
      hideLineNumbersForEditor(element.CodeMirror);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.saveCodeFromSyntaxHighlightEditors = () => {
    $.each($('.CodeMirror'), (i, editorDiv) => {
      editorDiv.CodeMirror.cyberDojoTextArea.value = editorDiv.CodeMirror.getValue();
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.saveCodeFromIndividualSyntaxHighlightEditor = (filename) => {
    const editorDiv = document.getElementById(syntaxHighlightFileContentForId(filename));
    editorDiv.CodeMirror.cyberDojoTextArea.value = editorDiv.CodeMirror.getValue();
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const plainTheme = 'cyber-dojo-default';
  const colourTheme = 'cyber-dojo-colour';
  const noLineNumbersTheme = ' cyber-dojo-no-linenumbers';

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const editorOptions = (filename) => {
    return {
         lineNumbers: true,
       matchBrackets: true,
                mode: codeMirrorMode(filename),
          indentUnit: cd.syntaxHighlightTabSize,
             tabSize: cd.syntaxHighlightTabSize,
      indentWithTabs: codeMirrorIndentWithTabs(filename),
               theme: plainTheme,
            readOnly: (filename == 'output'),
         smartIndent: false
    };
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const fileExtension = (filename) => {
    const lastPoint = filename.lastIndexOf('.');
    if (lastPoint == -1) {
      return '';
    } else {
      return filename.substring(lastPoint);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const codeMirrorMode = (filename) => {
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

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const codeMirrorIndentWithTabs = (filename) => {
    filename = filename.toLowerCase();
    switch (filename) {
      case 'makefile':
        return true;
      default:
        return false;
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const syntaxHighlightFileContentForId = (filename) => {
    return 'syntax_highlight_file_content_for_' + filename;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const runActionOnAllCodeMirrorEditors = (action) => {
    $.each($('.CodeMirror'), (i, editorDiv) => {
      action(editorDiv.CodeMirror);
    });
  };

  //================================================================

  const syntaxHighlightEnabled = () => {
    let enabled = false;
    runActionOnAllCodeMirrorEditors((editor) => {
      const theme = editor.getOption('theme');
      if (theme.indexOf(colourTheme) !== -1) {
        enabled = true;
      }
    });
    return enabled;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const enableSyntaxHighlight = (editor) => {
    let theme = editor.getOption('theme');
    theme = theme.replace(noLineNumbersTheme, '');
    editor.setOption('theme', colourTheme);
    editor.setOption('smartIndent', true);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const disableSyntaxHighlight = (editor) => {
    let theme = editor.getOption('theme');
    theme += noLineNumbersTheme;
    editor.setOption('theme', plainTheme);
    editor.setOption('smartIndent', false);
  };

  //================================================================

  const lineNumbersAreVisible = () => {
    let enabled = true;
    runActionOnAllCodeMirrorEditors((editor) => {
      const theme = editor.getOption('theme');
      if (theme.indexOf(noLineNumbersTheme) !== -1) {
        enabled = false;
      }
    });
    return enabled;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const showLineNumbersForEditor = (editor) => {
    let theme = editor.getOption('theme');
    theme = theme.replace(noLineNumbersTheme, '');
    editor.setOption('theme', theme);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const hideLineNumbersForEditor = (editor) => {
    let theme = editor.getOption('theme');
    theme += noLineNumbersTheme;
    editor.setOption('theme', theme);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const bindHotKeys = (editor) => {
    editor.setOption('extraKeys', {
      'Alt-T': (cm) => { $('#test-button').click(); },
      'Alt-J': (cm) => { loadNextFile(); },
      'Alt-K': (cm) => { loadPreviousFile(); },
      'Alt-O': (cm) => { cd.toggleOutputFile(); }
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const loadNextFile = () => {
    const hiFilenames = cd.hiFilenames(cd.filenames());
    const index = $.inArray(cd.currentFilename(), hiFilenames);
    if (index == -1) {
      const next = 0;
      cd.loadFile(hiFilenames[next]);
    } else {
      const next = (index + 1) % hiFilenames.length;
      cd.loadFile(hiFilenames[next]);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const loadPreviousFile = () => {
    const hiFilenames = cd.hiFilenames(cd.filenames());
    const index = $.inArray(cd.currentFilename(), hiFilenames)
    if (index === 0 || index === -1) {
      const previous = hiFilenames.length - 1;
      cd.loadFile(hiFilenames[previous]);
    } else {
      const previous = index - 1;
      cd.loadFile(hiFilenames[previous]);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
