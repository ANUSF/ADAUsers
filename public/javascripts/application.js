/* DO NOT MODIFY. This file was compiled Mon, 24 Jan 2011 02:35:40 GMT from
 * /home/olaf/Ruby-Rails/openid-server/app/coffeescripts/application.coffee
 */

(function() {
  var $, country_change;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery;
  country_change = function(item) {
    var form;
    form = item.closest('form#new_user');
    if (item.val() === "15") {
      form.find('#australia-inputs').css({
        display: 'block'
      });
      return form.find('#not-australia-inputs').css({
        display: 'none'
      });
    } else {
      form.find('#australia-inputs').css({
        display: 'none'
      });
      return form.find('#not-australia-inputs').css({
        display: 'block'
      });
    }
  };
  $(document).ready(function() {
    return $('form#new_user #user_country_input select').each(function() {
      return country_change($(this));
    }).change(function() {
      return setTimeout((__bind(function() {
        return country_change($(this));
      }, this)), 200);
    });
  });
}).call(this);
