/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.storeIncomingFileHashes = () => {
    incomingHashContainer().empty();
    $.each(cd.filenames(), (_,filename) => {
      incomingHashContainer().append(
        $('<input>', {
          'type': 'hidden',
          'data-filename': filename,
          'name': "file_hashes_incoming[" + filename + "]",
          'value': hashOf(filename)
        })
      );
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.storeOutgoingFileHashes = () => {
    outgoingHashContainer().empty();
    $.each(cd.filenames(), (_,filename) => {
      storeOutgoingFileHash(filename);
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const hashOf = (filename) => {
    const node = cd.fileContentFor(filename);
    const content = node.val();
    let hash = 0;
    for (let i = 0; i < content.length; ++i) {
      hash = (hash << 5) - hash + content.charCodeAt(i);
      hash &= hash;
    }
    return hash;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const outgoingHashContainer = () => {
    return $('#file_hashes_outgoing_container');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const incomingHashContainer = () => {
    return $('#file_hashes_incoming_container');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const storeOutgoingFileHash = (filename) => {
    $('input[data-filename="'+filename+'"]', outgoingHashContainer()).remove();
    outgoingHashContainer().append(
      $('<input>', {
        'type': 'hidden',
        'data-filename': filename,
        'name': "file_hashes_outgoing[" + filename + "]",
        'value': hashOf(filename)
      })
    );
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
