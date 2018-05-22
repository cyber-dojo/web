/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const hashOf = function(content) {
    let hash = 0;
    for (let i = 0; i < content.length; ++i) {
      hash = (hash << 5) - hash + content.charCodeAt(i);
      hash &= hash;
    }
    return hash;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const outgoingHashContainer = function() {
    return $('#file_hashes_outgoing_container');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const incomingHashContainer = function() {
    return $('#file_hashes_incoming_container');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const storeOutgoingFileHash = function(filename) {
    const node = cd.fileContentFor(filename);
    const hash = hashOf(node.val());
    $('input[data-filename="'+filename+'"]', outgoingHashContainer()).remove();
    outgoingHashContainer().append(
      $('<input>', {
        'type': 'hidden',
        'data-filename': filename,
        'name': "file_hashes_outgoing[" + filename + "]",
        'value': hash
      })
    );
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.storeOutgoingFileHashes = function() {
    outgoingHashContainer().empty();
    $.each(cd.filenames(), function(_,filename) {
      storeOutgoingFileHash(filename);
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.storeIncomingFileHashes = function() {
    incomingHashContainer().empty();
    $.each(cd.filenames(), function(_,filename) {
      const node = cd.fileContentFor(filename);
      const content = node.val();
      const hash = hashOf(content);
      incomingHashContainer().append(
        $('<input>', {
          'type': 'hidden',
          'data-filename': filename,
          'name': "file_hashes_incoming[" + filename + "]",
          'value': hash
        })
      );
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
