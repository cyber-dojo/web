/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.lib.setting = (name, value) => {
    // eg name = 'fork_button', eg value = 'on'
    value = override(value, cd.kata.manifest()[name]);
    value = override(value, cd.env[name.toUpperCase()]);
    return value;
  };

  const override = (current, newValue) => {
    return (newValue === "" || newValue === undefined) ? current : newValue;
  };

  return cd;

})(cyberDojo || {}, jQuery);
