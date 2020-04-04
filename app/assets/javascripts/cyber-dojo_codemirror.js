/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  const spaced = (words) => words.join('&nbsp');
  const disable = (id) => $(`#${id}`).attr('disabled', true);
  const enable  = (id) => $(`#${id}`).attr('disabled', false);

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const themeToDarkId       = 'theme-to-dark';
  const themeToDarkColourId = 'theme-to-dark-colour';

  let currentThemeId = themeToDarkId;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const codeMirrorTheme = () => {
    switch (currentThemeId) {
    case themeToDarkId:       return 'cyber-dojo-dark';
    case themeToDarkColourId: return 'cyber-dojo-dark-colour';
    default: //error
    }
  };

  const codeMirrorSmartIndent = () => {
    switch (currentThemeId) {
    case themeToDarkId:       return false;
    case themeToDarkColourId: return true;
    default: //error
    }
  };

  cd.themeToDarkButtonHtml = () => {
    const title = spaced(['set','theme','to','dark']);
    const myId = themeToDarkId;
    const disabled = (currentThemeId === myId) ? 'disabled' : '';
    return `<button type="button" id="${myId}"` +
      `onClick="cd.themeToDark();" ${disabled}>${title}</button>`;
  };
  cd.themeToDarkColourButtonHtml = () => {
    const title = spaced(['set','theme','to','dark','+','colour']);
    const myId = themeToDarkColourId;
    const disabled = (currentThemeId === myId) ? 'disabled' : '';
    return `<button type="button" id="${myId}"` +
      `onClick="cd.themeToDarkColour();" ${disabled}>${title}</button>`;
  };

  cd.themeToDark = () => {
    currentThemeId = themeToDarkId;
    runActionOnAllCodeMirrorEditors(setTheme);
    disable(themeToDarkId);
    enable(themeToDarkColourId);
  };
  cd.themeToDarkColour = () => {
    currentThemeId = themeToDarkColourId;
    runActionOnAllCodeMirrorEditors(setTheme);
    disable(themeToDarkColourId);
    enable(themeToDarkId);
  };

  const setTheme = (editor) => {
    editor.setOption('theme', codeMirrorTheme());
    editor.setOption('smartIndent', codeMirrorSmartIndent());
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
      element.CodeMirror.refresh();
      element.CodeMirror.focus();
    }
    if (currentThemeId === themeToDarkColourId) {
      setTheme(element.CodeMirror);
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
         lineNumbers: true,
       matchBrackets: true,
                mode: codeMirrorMode(filename),
          indentUnit: cd.syntaxHighlightTabSize,
             tabSize: cd.syntaxHighlightTabSize,
      indentWithTabs: codeMirrorIndentWithTabs(filename),
               theme: codeMirrorTheme(),
            readOnly: cd.isOutputFile(filename),
         smartIndent: codeMirrorSmartIndent()
    };
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const fileExtension = (filename) => {
    const lastPoint = filename.lastIndexOf('.');
    if (lastPoint === -1) {
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
      case 'readme.txt':
      case 'stdout':
      case 'stderr':
      case 'status':
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
      case '.rs':
        return 'text/x-rustsrc';
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
    return filename.toLowerCase() === 'makefile';
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

  const bindHotKeys = (editor) => {
    editor.setOption('extraKeys', {
      'Alt-T': () => $('#test-button').click(),
      'Alt-J': () => cd.loadNextFile(),
      'Alt-K': () => cd.loadPreviousFile(),
      'Alt-O': () => cd.toggleOutputFile()
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
