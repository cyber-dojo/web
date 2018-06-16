/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  'use strict';

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.inArray = function(find, array) {
    return $.inArray(find, array) !== -1;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.homePageUrl = function(id) {
    return '/dojo/index/' + id;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
