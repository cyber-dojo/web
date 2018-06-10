/*global jQuery,cyberDojo*/

var cyberDojo = (function(cd, $) {
  'use strict';

  cd.id = function(name) {
    return $('[id="' + name + '"]');
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.inArray = function(find, array) {
    return $.inArray(find, array) !== -1;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.homePageUrl = function(id) {
    return '/dojo/index/' + id;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.td = function(html) {
 	  return '<td>' + html + '</td>';
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  return cd;

})(cyberDojo || {}, jQuery);
