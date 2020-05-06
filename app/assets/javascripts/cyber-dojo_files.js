/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = (function(cd, $) {

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Filenames
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let theCurrentFilename = '';
  let theLastNonOutputFilename = '';
  let theLastOutputFilename = 'stdout';

  cd.currentFilename = () => theCurrentFilename;
  cd.eachFilename = (f) => cd.filenames().forEach(f);

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Load a named file
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadFile = (filename) => {
    // switch to showing filename's contents
    fileDiv(cd.currentFilename()).hide();
    fileDiv(filename).show();
    cd.focusSyntaxHighlightEditor(filename);
    // switch to showing filename
    selectFileInFileList(filename);
    // remember info for Alt-O hotkey
    theCurrentFilename = filename;
    if (cd.isOutputFile(filename)) {
      theLastOutputFilename = filename;
    } else {
      theLastNonOutputFilename = filename;
    }
  };

  const selectFileInFileList = (filename) => {
    // Can't do $('radio_' + filename) because filename
    // could contain characters that aren't strictly legal
    // characters in a dom node id so I do this instead...
    const node = $(`[id="radio_${filename}"]`);
    const previousFilename = cd.currentFilename();
    const previous = $(`[id="radio_${previousFilename}"]`);
    cd.radioEntrySwitch(previous, node);
    setRenameAndDeleteButtons(filename);
  };

  cd.radioEntrySwitch = (previous, current) => {
    // Used in test-page, and history/diff-dialog
    // See app/assets/stylesheets/wide-list-item.scss
    if (previous !== undefined) {
      previous.removeClass('selected');
    }
    $('.filename').removeClass('selected');
    current.addClass('selected');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadTestOutputFiles = (colour, stdout, stderr, status) => {
    cd.fileChange('stdout', { content: stdout });
    cd.fileChange('stderr', { content: stderr });
    cd.fileChange('status', { content: status });
    const empty = (s) => s.length === 0;
    switch (colour) {
      case 'timed_out':
      case 'faulty':
        cd.loadFile('status');
        break;
      case 'red':
      case 'green':
        if (!empty(stdout) || empty(stderr)) {
          cd.loadFile('stdout');
        } else {
          cd.loadFile('stderr');
        }
        break;
      case 'amber':
        if (stdout.length > stderr.length) {
          cd.loadFile('stdout');
        } else {
          cd.loadFile('stderr');
        }
        break;
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.filenames = () => {
    // Gets the kata/edit page filenames. The review/show
    // page/dialog collects filenames in its own way.
    const filenames = [];
    const prefix = 'file_content_for_';
    $(`textarea[id^=${prefix}]`).each(function(_) {
      const id = $(this).attr('id');
      const filename = id.substr(prefix.length, id.length - prefix.length);
      filenames.push(filename);
    });
    return filenames;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.sortedFilenames = (filenames) => {
    // Controls the order of files in the filename-list
    // Used in two places
    // 1. kata/edit page to help show filename-list
    // 2. review/show page/dialog to help show filename-list
    return [].concat(hiFilenames(filenames), loFilenames(filenames));
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Filename hot-key navigation
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // See app/assets/javascripts/cyber-dojo_codemirror.js
  // See app/views/shared/_hotkeys.html.erb
  // Alt-J ==> loadNextFile()
  // Alt-K ==> loadPreviousFile()
  // Alt-O ==> toggleOutputFile()

  cd.loadNextFile = () => {
    const hi = hiFilenames(cd.filenames());
    const index = $.inArray(cd.currentFilename(), hi);
    if (index === -1) {
      const next = 0;
      cd.loadFile(hi[next]);
    } else {
      const next = (index + 1) % hi.length;
      cd.loadFile(hi[next]);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadPreviousFile = () => {
    const hi = hiFilenames(cd.filenames());
    const index = $.inArray(cd.currentFilename(), hi);
    if (index === 0 || index === -1) {
      const previous = hi.length - 1;
      cd.loadFile(hi[previous]);
    } else {
      const previous = index - 1;
      cd.loadFile(hi[previous]);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.toggleOutputFile = () => {
    if (cd.isOutputFile(cd.currentFilename())) {
      cd.loadFile(theLastNonOutputFilename);
    } else {
      cd.loadFile(theLastOutputFilename);
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // hiFilenames() loFilenames()
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Controls which filenames appear at the top and bottom
  // of the filename-list. Used in three places.
  //   1. kata/edit page to help show filename list
  //   2. kata/edit page in alt-j alt-k hotkeys
  //   3. review/show page/dialog to help show filename list

  const hiFilenames = (filenames) => {
    return filenames
      .reject(filename => cd.isOutputFile(filename))
      .filter(filename => isSourceFile(filename))
      .sorted(highlightSorter);
  };

  const loFilenames = (filenames) => {
    return filenames
      .reject(filename => cd.isOutputFile(filename))
      .filter(filename => !isSourceFile(filename))
      .sorted();
  };

  const highlightSorter = (lhs,rhs) => {
    const lit = cd.highlightFilenames();
    const lhsLit = lit.includes(lhs);
    const rhsLit = lit.includes(rhs);
    if (lhsLit && !rhsLit) {
      return -1;
    } else if (!lhsLit && rhsLit) {
      return +1;
    } else if (lhs < rhs) {
      return -1;
    } else if (lhs > rhs) {
      return +1;
    } else {
      return 0;
    }
  };

  Array.prototype.reject = function(f) {
    return this.filter(item => !f(item));
  };

  Array.prototype.sorted = function(f) {
    this.sort(f);
    return this;
  };

  cd.isOutputFile = (filename) => {
    return ['stdout','stderr','status','repl'].includes(filename);
  };

  const isSourceFile = (filename) => {
    // Shell test frameworks (eg shunit2) use .sh as their
    // filename extension but we don't want cyber-dojo.sh
    return filename !== 'cyber-dojo.sh' &&
      cd.extensionFilenames().find(ext => filename.endsWith(ext));
      // filename === 'readme.txt'
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // new-file, rename-file, delete-file
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // See app/views/kata/_file_new_rename_delete.html.erb
  // See app/views/kata/_files.html.erb
  // See app/views/kata/_run_tests.js.erb

  cd.fileChange = (filename, file) => {
    cd.fileDelete(filename);
    cd.fileCreate(filename, file);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.fileCreate = (filename, file) => {
    const newFile = makeNewFile(filename, file);
    $('#visible-files-box').append(newFile);
    rebuildFilenameList();
    cd.switchEditorToCodeMirror(filename);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.fileDelete = (filename) => {
    fileDiv(filename).remove();
    rebuildFilenameList();
    theLastNonOutputFilename = testFilename();
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.fileRename = (oldFilename, newFilename) => {
    // This should restore the caret/cursor/selection
    // but it currently does not. See
    // https://github.com/cyber-dojo/web/issues/51
    const content = fileContent(oldFilename);
    cd.fileDelete(oldFilename);
    cd.fileCreate(newFilename, { content:content });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Helpers
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.editorRefocus = () => {
    cd.loadFile(cd.currentFilename());
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loadInitialFile = () => {
    if (cd.filenames().includes('readme.txt')) {
      cd.loadFile('readme.txt');
    } else {
      cd.loadFile(testFilename());
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const testFilename = () => {
    // When starting and in filename-list navigation
    // when the current file is deleted, try to
    // select a test file.
    const filenames = cd.filenames();
    for (let i = 0; i < filenames.length; i++) {
      // split into dir names and filename
      const parts = filenames[i].toLowerCase().split('/');
      // careful to return the whole dirs+filename
      // and with the original case
      const filename = parts[parts.length - 1];
      if (filename.search('test') !== -1) {
        return filenames[i];
      }
      if (filename.search('spec') !== -1) {
        return filenames[i];
      }
    }
    return filenames[0];
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const fileContent = (filename) => {
    cd.saveCodeFromIndividualSyntaxHighlightEditor(filename);
    return jqElement(`file_content_for_${filename}`).val();
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const jqElement = (name) => {
    return $(`[id="${name}"]`);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const fileDiv = (filename) => {
    return jqElement(`${filename}_div`);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const makeNewFile = (filename, file) => {
    const div = $('<div>', {
        class: 'filename_div',
           id: `${filename}_div`
    });
    const text = $('<textarea>', {
      class: 'file_content',
      name: `file_content[${filename}]`,
      id: `file_content_for_${filename}`,
      'spellcheck': 'false',
      'data-filename': filename,
      text: file['content']
    });
    div.append(text);

    return div;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const setRenameAndDeleteButtons = (filename) => {
    const renameFile = $('.rename-file');
    const deleteFile = $('.delete-file');
    const disable = (node) => node.prop('disabled', true );
    const enable  = (node) => node.prop('disabled', false);

    if (cantBeRenamedOrDeleted(filename)) {
      disable(renameFile);
      disable(deleteFile);
    } else {
      enable(renameFile);
      enable(deleteFile);
    }
  };

  const cantBeRenamedOrDeleted = (filename) => {
    return cd.isOutputFile(filename) || filename == 'cyber-dojo.sh';
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const rebuildFilenameList = () => {
    const filenameList = $('#filename-list');
    filenameList.empty();
    $.each(cd.sortedFilenames(cd.filenames()), (_, filename) => {
      filenameList.append(makeFileListEntry(filename));
    });
  };

  const makeFileListEntry = (filename) => {
    const div = $('<div>', {
        class: 'filename',
           id: `radio_${filename}`,
         text: filename
    });
    if (cd.inArray(filename, cd.highlightFilenames())) {
      div.addClass('highlight');
    }
    div.click(() => { cd.loadFile(filename); });
    return div;
  };

  return cd;

})(cyberDojo || {}, jQuery);
