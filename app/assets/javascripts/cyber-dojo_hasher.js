/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  "use strict";

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.storeIncomingFileHashes = () => {
    const container = $('#file_hashes_incoming_container');
    container.empty();
    cd.eachFilename((filename) => {
      container.append(inputHash('incoming', filename));
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.storeOutgoingFileHashes = () => {
    const container = $('#file_hashes_outgoing_container');
    container.empty();
    cd.eachFilename((filename) => {
      container.append(inputHash('outgoing', filename));
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  const inputHash = (io, filename) => {
    return $('<input>', {
      'type': 'hidden',
      'data-filename': filename,
      'name': 'file_hashes_' + io + '[' + filename + ']',
      'value': hashOf(filename)
    })
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

  return cd;

})(cyberDojo || {}, jQuery);
