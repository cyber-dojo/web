/*global jQuery*/
'use strict';
(($) => {
  $(document).ajaxSend((event, xhr, settings) => {
    if (settings.type !== 'GET') {
      const token = $('meta[name="csrf-token"]').attr('content');
      settings.data = (settings.data ? settings.data + '&' : '') +
        'authenticity_token=' + encodeURIComponent(token);
    }
  });
})(jQuery);
