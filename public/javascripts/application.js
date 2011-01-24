/* DO NOT MODIFY. This file was compiled Mon, 24 Jan 2011 04:39:11 GMT from
 * /home/olaf/Ruby-Rails/openid-server/app/coffeescripts/application.coffee
 */

(function() {
  var $, checked_radio_button, country_change, institution_change, patterns;
  $ = jQuery;
  patterns = {
    form: 'form#new_user',
    country_selection: '#user_country_input select',
    affiliation_aus: '#affiliation-aus',
    affiliation_non_aus: '#affiliation-non-aus',
    inst_type_container: '#user_austinstitution_input',
    inst_buttons_name: 'user[austinstitution]',
    inst_type_conditional_fields: {
      Uni: '#user_australian_uni_input',
      Dept: '#user_australian_gov_input',
      Other: '#user_australian_other_inputs'
    }
  };
  checked_radio_button = function(scope, name) {
    return scope.find("input[@name='" + name + "']:checked");
  };
  country_change = function(item) {
    var aus, form, other;
    form = item.closest(patterns.form);
    aus = form.find(patterns.affiliation_aus);
    other = form.find(patterns.affiliation_non_aus);
    if (item.val() === "15") {
      aus.show();
      return other.hide();
    } else {
      aus.hide();
      return other.show();
    }
  };
  institution_change = function(item) {
    var form, k, v, value, _ref, _results;
    form = item.closest(patterns.form);
    value = checked_radio_button(form, patterns.inst_buttons_name).val();
    _ref = patterns.inst_type_conditional_fields;
    _results = [];
    for (k in _ref) {
      v = _ref[k];
      _results.push(form.find(v)[k === value ? 'show' : 'hide']());
    }
    return _results;
  };
  $(document).ready(function() {
    $(patterns.form).find(patterns.country_selection).each(function() {
      return country_change($(this));
    }).change(function() {
      return country_change($(this));
    });
    return $(patterns.form).find(patterns.inst_type_container).each(function() {
      return institution_change($(this));
    }).find('input').click(function() {
      return institution_change($(this));
    });
  });
}).call(this);
