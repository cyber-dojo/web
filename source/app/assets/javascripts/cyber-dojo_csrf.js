/*global jQuery*/
'use strict';
(($) => {
  $(document).ajaxSend((event, xhr, settings) => {
    if (settings.type !== 'GET') {
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
    }
  });
})(jQuery);
