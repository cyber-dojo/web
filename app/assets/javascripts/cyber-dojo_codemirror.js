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

  cd.switchEditorToCodeMirror = function(filename, tab_size) {
    var editor = CodeMirror.fromTextArea(document.getElementById('file_content_for_' + filename),  {
        lineNumbers: true,
        matchBrackets: true,
        mode: cd.codeMirrorMode(filename),
        autoRefresh: true,
        indentUnit: tab_size,
        tabSize: tab_size,
        theme: "default cyber-dojo"
    });

    editor.setOption("extraKeys", {
        'Alt-T': function(cm) {
            $('#test-button').click();
        }
    });
    var lineNumbers = document.getElementById(filename + '_line_numbers');
    lineNumbers.style.display = 'none';
  };

  cd.switchTheme = function() {
    var themeDropDown = document.getElementById('code-mirror-theme');
    var index = themeDropDown.selectedIndex;
    var selectedItem = themeDropDown.options[index];
    $.each($('.CodeMirror'), function(i, editor_div) {
      editor_div.CodeMirror.setOption("theme", 'default ' + selectedItem.value);
      editor_div.CodeMirror.refresh();
    });
  };


  return cd;

})(cyberDojo || {}, jQuery);
