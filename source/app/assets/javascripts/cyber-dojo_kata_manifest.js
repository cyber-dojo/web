/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  let kataManifestCache = undefined;

  cd.kata.manifest = (id = cd.kata.id) => {
    if (kataManifestCache === undefined) {
      $.ajax({
              type: 'GET',
               url: `/saver/kata_manifest?id=${id}`,
          dataType: 'json',
             async: false,
           success: (response) => {
             kataManifestCache = response.kata_manifest;
           }
      });
    }
    return kataManifestCache;
  };

  return cd;

})(cyberDojo || {}, jQuery);
