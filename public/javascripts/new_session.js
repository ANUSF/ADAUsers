/* DO NOT MODIFY. This file was compiled Fri, 03 Jun 2011 06:30:00 GMT from
 * /home/olaf/Rails/ada-users/app/coffeescripts/new_session.coffee
 */

(function() {
  $(document).ready(function() {
    $(window).unload(function() {
      return $.post('/session', {
        commit: 'Cancel'
      });
    });
    return $('#main form input[name=commit]').click(function() {
      return $(window).unbind('unload');
    });
  });
}).call(this);
