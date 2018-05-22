/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.fileContentFor = function(filename) {
    return cd.id('file_content_for_' + filename);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.fileDiv = function(filename) {
    return cd.id(filename + '_div');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.makeNewFile = function(filename, content) {
    var div = $('<div>', {
      'class': 'filename_div',
      id: filename + '_div'
    });
    var table = $('<table>');
    var tr = $('<tr>');
    var td2 = $('<td>');
    var text = $('<textarea>', {
      'class': 'file_content',
      'spellcheck': 'false',
      'data-filename': filename,
      name: 'file_content[' + filename + ']',
      id: 'file_content_for_' + filename
      //
      //wrap: 'off'
      //
    });
    // For some reason, setting wrap cannot be done as per the
    // commented out line above... when you create a new file in
    // FireFox 17.0.1 it still wraps at the textarea width.
    // So instead I do it like this, which works in FireFox?!
    text.attr('wrap', 'off');

    text.val(content);
    td2.append(text);
    tr.append(td2);
    table.append(tr);
    div.append(table);

    return div;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.testFilenameIndex = function(filenames) {
    // When starting and in file-knave navigation
    // the current file is sometimes not present.
    // (eg the file has been renamed/deleted).
    // When this happens, try to select a test file.
    var i,parts,filename;
    for (i = 0; i < filenames.length; i++) {
      parts = filenames[i].toLowerCase().split('/');
      filename = parts[parts.length - 1];
      if (filename.search('test') !== -1) {
        return i;
      }
    }
    return 0;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.newFileContent = function(filename, content) {
    const newFile = cd.makeNewFile(filename, content);
    $('#visible-files-container').append(newFile);
    cd.rebuildFilenameList();
    cd.loadFile(filename);
    cd.switchEditorToCodeMirror(filename);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.deleteFile = function(filename) {
    cd.fileDiv(filename).remove();
    const filenames = cd.rebuildFilenameList();
    const i = cd.testFilenameIndex(filenames);
    cd.loadFile(filenames[i]);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.editorRefocus = function() {
    cd.loadFile(cd.currentFilename());
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const cantBeRenamedOrDeleted = function(filename) {
    const filenames = [ 'cyber-dojo.sh', 'output' ];
    return cd.inArray(filename, filenames);
  };

  cd.setRenameAndDeleteButtons = function(filename) {
    const fileOps = $('#file-operations');
    const   newFile  = fileOps.find('#new');
    const renameFile = fileOps.find('#rename');
    const deleteFile = fileOps.find('#delete');
    const disable = function(node) { node.prop('disabled', true); };
    const enable  = function(node) { node.prop('disabled', false); };

    if (cantBeRenamedOrDeleted(filename)) {
      disable(renameFile);
      disable(deleteFile);
    } else {
      enable(renameFile);
      enable(deleteFile);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.selectFileInFileList = function(filename) {
    // Can't do $('radio_' + filename) because filename
    // could contain characters that aren't strictly legal
    // characters in a dom node id so I do this instead...
    const node = $('[id="radio_' + filename + '"]');
    const previousFilename = cd.currentFilename();
    const previous = $('[id="radio_' + previousFilename + '"]');
    cd.radioEntrySwitch(previous, node);
    cd.setRenameAndDeleteButtons(filename);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.radioEntrySwitch = function(previous, current) {
    // Used in test-page, setup-page, and history-dialog
    if (previous != undefined) {
      previous.removeClass('selected');
    }
    current.addClass('selected');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadNextFile = function() {
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

  cd.loadPreviousFile = function() {
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

  var theCurrentFilename = '';
  var theLastNonOutputFilename = '';

  cd.currentFilename = function() {
    return theCurrentFilename;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadFile = function(filename) {
    cd.fileDiv(cd.currentFilename()).hide();
    cd.selectFileInFileList(filename);
    cd.fileDiv(filename).show();

    cd.fileContentFor(filename).focus();
    cd.focusSyntaxHighlightEditor(filename);
    theCurrentFilename = filename;
    if (filename !== 'output') {
      theLastNonOutputFilename = filename;
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.toggleOutputFile = function() {
    if (cd.currentFilename() !== 'output') {
      cd.loadFile('output');
    } else {
      cd.loadFile(theLastNonOutputFilename);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;
})(cyberDojo || {}, jQuery);
