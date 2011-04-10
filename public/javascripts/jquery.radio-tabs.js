/* DO NOT MODIFY. This file was compiled Sun, 10 Apr 2011 23:20:46 GMT from
 * /home/rmm900/dev/ADAUsers/app/coffeescripts/jquery.radio-tabs.coffee
 */

(function() {
  jQuery.fn.radioTabs = function() {
    var container, radioTabsUpdate;
    container = jQuery(this);
    radioTabsUpdate = function() {
      return container.find(".radio-tabs-tabs input[type=radio]").each(function(i) {
        var content;
        content = container.find(".radio-tab-option[data-option-name=" + jQuery(this).val() + "]");
        if (jQuery(this).is(":checked")) {
          return content.show();
        } else {
          return content.hide();
        }
      });
    };
    container.find("input[type=radio]").click(radioTabsUpdate);
    return radioTabsUpdate();
  };
}).call(this);
