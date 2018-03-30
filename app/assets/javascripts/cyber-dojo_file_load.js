/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  cd.loadFile = function(filename) {
    cd.fileDiv(cd.currentFilename()).hide();
    cd.selectFileInFileList(filename);
    cd.fileDiv(filename).show();

    cd.fileContentFor(filename).focus();
    cd.focusSyntaxHighlightEditor(filename);
    $('#current-filename').val(filename);
    if (filename !== 'output') {
      $('#last-non-output-filename').val(filename);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.setRenameAndDeleteButtons = function(filename) {
    var fileOps = $('#file-operations');
    var   newFile  = fileOps.find('#new');
    var renameFile = fileOps.find('#rename');
    var deleteFile = fileOps.find('#delete');
    var disable = function(node) { node.prop('disabled', true); };
    var enable  = function(node) { node.prop('disabled', false); };

    if (cd.cantBeRenamedOrDeleted(filename)) {
      disable(renameFile);
      disable(deleteFile);
    } else {
      enable(renameFile);
      enable(deleteFile);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.cantBeRenamedOrDeleted = function(filename) {
    var filenames = [ 'cyber-dojo.sh', 'output' ];
    return cd.inArray(filename, filenames);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.selectFileInFileList = function(filename) {
    // Can't do $('radio_' + filename) because filename
    // could contain characters that aren't strictly legal
    // characters in a dom node id so I do this instead...
    var node = $('[id="radio_' + filename + '"]');
    var previousFilename = cd.currentFilename();
    var previous = $('[id="radio_' + previousFilename + '"]');
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
    var hiFilenames = cd.hiFilenames(cd.filenames());
    var index = $.inArray(cd.currentFilename(), hiFilenames);
    if (index == -1) {
      index = 0;
    } else {
      index = (index + 1) % hiFilenames.length;
    }
    cd.loadFile(hiFilenames[index]);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadPreviousFile = function() {
    var hiFilenames = cd.hiFilenames(cd.filenames());
    var index = $.inArray(cd.currentFilename(), hiFilenames);
    if (index === 0 || index === -1) {
      index = hiFilenames.length - 1;
    } else {
      index -= 1;
    }
    cd.loadFile(hiFilenames[index]);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.toggleOutputFile = function() {
    if (cd.currentFilename() !== 'output') {
      cd.loadFile('output');
    } else {
      cd.loadFile($('#last-non-output-filename').val());
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;
})(cyberDojo || {}, jQuery);
