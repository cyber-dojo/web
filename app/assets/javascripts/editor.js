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

  Editor.prototype.renameFile = function(oldFilename, newFilename) {
    // This should restore the caret/cursor/selection
    // but it currently does not. See
    // https://github.com/cyber-dojo/web/issues/51
    const content = fileContent(oldFilename);
    this.deleteFile(oldFilename);
    this.createFile(newFilename, { content:content });
  };

  Editor.prototype.hideFile = function(filename) {
    $fileDiv(filename).hide();
  };

  Editor.prototype.showFile = function(filename) {
    $fileDiv(filename).show();
  };

  Editor.prototype.changeFile = function(filename, file) {
    this.deleteFile(filename);
    this.createFile(filename, file);    
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

  const fileContent = (filename) => {
    cd.saveCodeFromIndividualSyntaxHighlightEditor(filename);
    return $jqElement(`file_content_for_${filename}`).val();
  };

  const $fileDiv = (filename) => $jqElement(`${filename}_div`);

  const $jqElement = (name) => $(`[id="${name}"]`);

  // - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
