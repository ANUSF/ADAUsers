/* DO NOT MODIFY. This file was compiled Wed, 13 Apr 2011 03:44:14 GMT from
 * /home/rmm900/dev/ADAUsers/app/coffeescripts/application.coffee
 */

(function() {
  var $, action_change, country_change, institution_change, patterns, position_change, process_admin_undertaking_form, process_registration_form, process_undertaking_form;
  $ = jQuery;
  patterns = {
    form: 'form.user',
    position_selection: '#user_position_input select',
    other_position: '#user_otherpd_input',
    action_selection: '#user_action_input select',
    other_action: '#user_otherwt_input',
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
  position_change = function(item) {
    var other;
    other = item.closest(patterns.form).find(patterns.other_position);
    if (item.val() === 'Other') {
      return other.show();
    } else {
      return other.hide();
    }
  };
  action_change = function(item) {
    var other;
    other = item.closest(patterns.form).find(patterns.other_action);
    if (item.val() === 'Other') {
      return other.show();
    } else {
      return other.hide();
    }
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
    var form, k, pattern, v, value, _ref, _results;
    form = item.closest(patterns.form);
    pattern = "input[@name='" + patterns.inst_buttons_name + "']:checked";
    value = form.find(pattern).val();
    _ref = patterns.inst_type_conditional_fields;
    _results = [];
    for (k in _ref) {
      v = _ref[k];
      _results.push(form.find(v)[k === value ? 'show' : 'hide']());
    }
    return _results;
  };
  process_registration_form = function() {
    var form;
    if ((form = $(patterns.form)) != null) {
      form.find(patterns.position_selection).each(function() {
        return position_change($(this));
      }).change(function() {
        return position_change($(this));
      });
      form.find(patterns.action_selection).each(function() {
        return action_change($(this));
      }).change(function() {
        return action_change($(this));
      });
      form.find(patterns.country_selection).each(function() {
        return country_change($(this));
      }).change(function() {
        return country_change($(this));
      });
      return form.find(patterns.inst_type_container).each(function() {
        return institution_change($(this));
      }).find('input').click(function() {
        return institution_change($(this));
      });
    }
  };
  process_undertaking_form = function() {
    var dataset_select, form, handle_use_intended_use_type_thesis_click;
    if ($("#undertaking_intended_use_type_input").length > 0) {
      handle_use_intended_use_type_thesis_click = function() {
        var checked, field;
        checked = $("#undertaking_intended_use_type_thesis").is(":checked");
        field = $("li#undertaking_email_supervisor_input");
        if (checked) {
          return field.slideDown();
        } else {
          return field.slideUp();
        }
      };
      $("#undertaking_intended_use_type_thesis").click(handle_use_intended_use_type_thesis_click);
      handle_use_intended_use_type_thesis_click();
    }
    if (((form = $("form.undertaking")) != null) && $("#undertaking_catalogue").length > 0) {
      dataset_select = form.find("#undertaking_dataset_ids");
      dataset_select.empty();
      return form.find("#undertaking_catalogue").change(function() {
        dataset_select.empty().addClass("loading");
        return $.ajax({
          url: "/datasets/restricted/" + $(this).val(),
          success: function(html) {
            return dataset_select.html(html);
          },
          complete: function() {
            return dataset_select.removeClass("loading");
          }
        });
      });
    }
  };
  process_admin_undertaking_form = function() {
    if ($("table.admin-undertakings").length > 0) {
      $("tr.admin-undertaking-details div").hide();
      return $("tr.admin-undertaking-summary").click(function() {
        return $(this).next().find("div").slideToggle();
      });
    }
  };
  $(document).ready(function() {
    process_registration_form();
    process_undertaking_form();
    process_admin_undertaking_form();
    $("select.filterable").selectFilter();
    return $(".radio-tabs").radioTabs();
  });
}).call(this);
