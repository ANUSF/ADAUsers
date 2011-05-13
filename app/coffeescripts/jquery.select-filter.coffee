jQuery.fn.selectFilter = ->
  jQuery(this).each (index) ->
    # Add the filter in a new div, and move the select input into that div
    jQuery(this).before('<div class="select-filter-container">Filter: <input type="text" class="select-filter" /><br /></div>')
    container = jQuery(this).prev()
    container.append(jQuery(this).detach())

    # Store a copy of the options
    jQuery(this).data("options", jQuery(this).find("option"))

    jQuery(".select-filter").keyup ->
      query = jQuery(this).val()
      select = jQuery(this).next().next()

      select.empty()
      select.append select.data("options").filter (index) ->
        jQuery(this).html().toLowerCase().indexOf(query.toLowerCase()) > -1
