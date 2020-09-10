/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.codeMirror = {
    resetTheme: () => {
      runActionOnAllCodeMirrorEditors(setTheme);
    }
  };

  const setTheme = (editor) => {
    editor.setOption('theme', codeMirrorTheme());
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const codeMirrorTheme = () => {
    // There are four CodeMirror css themes. Their names are the formed
    // by combining the two theme values and the two colour values.
    //   dark-colour-on
    //   dark-colour-off
    //   light-colour-on
    //   light-colour-off
    return [
      'cyber-dojo',
      cd.settings.theme(),
      'colour',
      cd.settings.colour()
    ].join('-');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.switchEditorToCodeMirror = (filename) => {
    const textArea = document.getElementById(`file_content_for_${filename}`);
    const parent = textArea.parentNode;
    const editor = CodeMirror(parent, editorOptions(filename));

    textArea.style.display = 'none';
    editor.cyberDojoTextArea = textArea;
    editor.setValue(textArea.value);
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
    if (element !== null) {
      setTheme(element.CodeMirror);
      element.CodeMirror.refresh();
      element.CodeMirror.focus();
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

  const editorOptions = (filename) => {
    return {
          indentUnit: cd.kata.editor.tabSize(),
            readOnly: cd.kata.tabs.reserves(filename),
             tabSize: cd.kata.editor.tabSize(),
         lineNumbers: true,
       matchBrackets: true,
         smartIndent: true,
      indentWithTabs: codeMirrorIndentWithTabs(filename),
        lineWrapping: codeMirrorLineWrapping(filename),
                mode: codeMirrorMode(filename),
               theme: codeMirrorTheme(),
    };
  };

  const codeMirrorLineWrapping = (filename) => {
    return ['readme.txt', 'output'].includes(filename);
  };

  const codeMirrorIndentWithTabs = (filename) => {
    return filename.toLowerCase() === 'makefile';
  };

  const codeMirrorMode = (filename) => {
    filename = filename.toLowerCase();
    if (filename === 'makefile') {
      return 'text/x-makefile';
    }
    if (filename === 'output') {
      return 'text/x-output';
    }
    switch (fileExtension(filename)) {
      // C/C++ have split source
      case '.c'      : return 'text/x-csrc';
      case '.cpp'    : return 'text/x-c++src';
      case '.hpp'    : return 'text/x-c++hdr';
      case '.h'      : return 'text/x-c++hdr';
      // all the rest don't
      case '.clj'    : return 'text/x-clojure';
      case '.coffee' : return 'text/x-coffeescript';
      case '.cs'     : return 'text/x-csharp';
      case '.d'      : return 'text/x-d';
      case '.feature': return 'text/x-feature';
      case '.go'     : return 'text/x-go';
      case '.groovy' : return 'text/x-groovy';
      case '.htm'    : return 'text/html';
      case '.html'   : return 'text/html';
      case '.hs'     : return 'text/x-haskell';
      case '.java'   : return 'text/x-java';
      case '.js'     : return 'text/javascript';
      case '.md'     : return 'text/x-markdown';
      case '.php'    : return 'text/x-php';
      case '.py'     : return 'text/x-python';
      case '.rb'     : return 'text/x-ruby';
      case '.rs'     : return 'text/x-rustsrc';
      case '.scala'  : return 'text/x-scala';
      case '.sh'     : return 'text/x-sh';
      case '.swift'  : return 'text/x-swift';
      case '.vb'     : return 'text/x-vb';
      case '.vhdl'   : return 'text/x-vhdl';
      case '.xml'    : return 'text/xml';
    }
    return '';
  };

  const fileExtension = (filename) => {
    const lastPoint = filename.lastIndexOf('.');
    if (lastPoint === -1) {
      return '';
    } else {
      return filename.substring(lastPoint);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const syntaxHighlightFileContentForId = (filename) => {
    return `syntax_highlight_file_content_for_${filename}`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const runActionOnAllCodeMirrorEditors = (action) => {
    $.each($('.CodeMirror'), (_i, editorDiv) => {
      action(editorDiv.CodeMirror);
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const runTests = () => {
    $('#test-button').click();
    return false;
  };

  const selectNext = () => {
    cd.kata.filenames.selectNext();
    return false;
  };

  const selectPrevious = () => {
    cd.kata.filenames.selectPrevious();
    return false;
  };

  const toggleOutput = () => {
    cd.kata.tabs.toggle();
    return false;
  };

  const bindHotKeys = (editor) => {
    editor.setOption('extraKeys', {
      'Alt-T': runTests,
      'Alt-J': selectNext,
      'Alt-K': selectPrevious,
      'Alt-O': toggleOutput
    });
  };

  cd.setupHotkeys = () => {
    // Called from app/views/kata/edit.html.erb
    $(document).bind('keyup', 'alt+t', runTests);
    $(document).bind('keyup', 'alt+j', selectNext);
    $(document).bind('keyup', 'alt+k', selectPrevious);
    $(document).bind('keyup', 'alt+o', toggleOutput);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
