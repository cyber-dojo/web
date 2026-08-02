/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.kata.editor = new Editor();

  function Editor() {
    this.currentFilename = undefined;
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

  Editor.prototype.deleteFiles = function() {
    this.filenames().forEach((filename) => this.deleteFile(filename));
  };

  Editor.prototype.hideFile = function(filename) {
    if (this.currentFilename === filename) {
      this.currentFilename = undefined;
    }
    $fileDiv(filename).hide();
  };

  Editor.prototype.showFile = function(filename) {
    if (this.currentFilename !== undefined) {
      this.hideFile(this.currentFilename);
    }
    $fileDiv(filename).show();
    this.currentFilename = filename;
    this.refocus();
  };

  Editor.prototype.hideCurrentFile = function() {
    if (this.currentFilename !== undefined) {
      this.hideFile(this.currentFilename);
    }
  };

  Editor.prototype.changeFile = function(filename, file) {
    this.deleteFile(filename);
    this.createFile(filename, file);
  };

  Editor.prototype.output = function(stdout, stderr, status) {
    this.changeFile('output', { content:
      ":stdout:\n" + stdout + "\n" +
      ":stderr:\n" + stderr + "\n" +
      ":status:\n" + status + "\n"
    });
  };

  Editor.prototype.refocus = function() {
    cd.focusSyntaxHighlightEditor(this.currentFilename);
  };

  Editor.prototype.filenames = function() {
    const filenames = [];
    const prefix = 'file_content_for_';
    $(`textarea[id^=${prefix}]`).each(function(_) {
      const id = $(this).attr('id');
      const filename = id.substr(prefix.length, id.length - prefix.length);
      filenames.push(filename);
    });
    return filenames;
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
      text: file.content
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
