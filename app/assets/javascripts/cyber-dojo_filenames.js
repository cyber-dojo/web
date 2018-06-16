/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.eachFilename = (f) => {
    cd.filenames().forEach(f);
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.filenames = () => {
    // Gets the kata/edit page filenames.
    // The review/show page/dialog has to collect its filenames
    // in its own way.
    const filenames = [];
    const prefix = 'file_content_for_';
    $('textarea[id^=' + prefix + ']').each(function(_) {
      const id = $(this).attr('id');
      const filename = id.substr(prefix.length, id.length - prefix.length);
      filenames.push(filename);
    });
    return filenames;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const isSourceFile = (filename) => {
    let match = false;
    $.each(cd.extensionFilenames(), (_, extension) => {
      // Shell test frameworks (eg shunit2) use .sh as their
      // filename extension but we don't want cyber-dojo.sh
      // in the hiFilenames() above output in the filename-list.
      if (filename.endsWith(extension) && filename != 'cyber-dojo.sh') {
        match = true;
      }
    });
    return match;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.hiFilenames = (filenames) => {
    // Controls which filenames appear at the
    // top of the filename-list, above 'output'
    //
    // Used in three places.
    // 1. kata/edit page to help show filename list
    // 2. kata/edit page in alt-j alt-k hotkeys
    // 3. review/show page/dialog to help show filename list
    //
    let hi = [];
    $.each(filenames, function(_, filename) {
      if (isSourceFile(filename) || filename == 'instructions') {
        hi.push(filename);
      }
    });
    hi.sort();
    hi = hi.filter(item => item !== 'output')
    hi = hi.filter(item => item != 'cyber-dojo.sh')
    return hi;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.loFilenames = (filenames) => {
    // Controls which filenames appear at the
    // bottom of the filename list, below 'output'
    //
    // Used in three places.
    // 1. kata/edit page to help show filename-list
    // 2. kata/edit page in Alt-j Alt-k hotkeys
    // 3. review/show page/dialog to help show filename-list
    //
    let lo = [];
    $.each(filenames, (_, filename) => {
      if (!isSourceFile(filename) && filename != 'instructions') {
        lo.push(filename);
      }
    });
    lo.sort();
    lo = lo.filter(item => item !== 'output')
    return lo;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.sortedFilenames = (filenames) => {
    // Controls the order of files in the filename-list
    // Used in two places
    //
    // 1. kata/edit page to help show filename-list
    // 2. review/show page/dialog to help show filename-list
    //
    return [].concat(cd.hiFilenames(filenames), ['output'], cd.loFilenames(filenames));
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.rebuildFilenameList = () => {
    const filenames = cd.filenames();
    const filenameList = $('#filename-list');
    filenameList.empty();
    $.each(cd.sortedFilenames(filenames), (_, filename) => {
      filenameList.append(makeFileListEntry(filename));
    });
    return filenames;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const makeFileListEntry = (filename) => {
    const div = $('<div>', {
      'class': 'filename',
      id: 'radio_' + filename,
      text: filename
    });
    if (cd.inArray(filename, cd.highlightFilenames())) {
      div.addClass('highlight');
    }
    div.click(() => { cd.loadFile(filename); });
    return div;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
