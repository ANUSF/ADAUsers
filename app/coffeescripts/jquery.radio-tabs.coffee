############################################################
# Radio tabs jQuery plugin
# Written by Rohan Mitchell
# Copyright Australian National University, 2011
#
# Usage:
#
# Provide markup like:
#
# <div class="radio-tabs">
#   <div class="radio-tabs-tabs">
#     <!-- Radio buttons go here -->
#   </div>
#
#   <div class="radio-tab-option" data-option-name="your-radio-value">
#     <!-- Content goes here -->
#   </div>
# </div>
#
#
# Then call:
# $(".radio-tabs").radioTabs();
#

jQuery.fn.radioTabs = ->
  container = jQuery(this)

  radioTabsUpdate = ->
    container.find(".radio-tabs-tabs input[type=radio]").each (i) ->
      content = container.find(".radio-tab-option[data-option-name="+jQuery(this).val()+"]")
      if jQuery(this).is(":checked") then content.show() else content.hide()

  container.find("input[type=radio]").click(radioTabsUpdate)
  radioTabsUpdate()

