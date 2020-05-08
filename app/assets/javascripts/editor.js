/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.kata.editor = new Editor();

  function Editor() {
  };

  Editor.prototype.createFiles = function(files) {
    files.forEach(file => {
      this.createFile(file.name, file);
    });
  };

  Editor.prototype.createFile = function(filename, file) {
    const $newFile = $makeNewFile(filename, file);
    $('#visible-files-box').append($newFile);
    cd.switchEditorToCodeMirror(filename);
  };

  Editor.prototype.deleteFile = function(filename) {
    $fileDiv(filename).remove();
  };

  // - - - - - - - - - - - - - - - - - - - - - -

  const $makeNewFile = (filename, file) => {
    const $div = $('<div>', {
        class: 'filename_div',
           id: `${filename}_div`
    });
    const $text = $('<textarea>', {
      class: 'file_content',
      name: `file_content[${filename}]`,
      id: `file_content_for_${filename}`,
      'spellcheck': 'false',
      'data-filename': filename,
      text: file['content']
    });
    $div.append($text);
    return $div;
  };

  const $fileDiv = (filename) => $jqElement(`${filename}_div`);

  const $jqElement = (name) => $(`[id="${name}"]`);

  // - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
